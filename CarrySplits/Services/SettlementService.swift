import Foundation

enum SettlementService {
    static func balances(
        participantIDs: [UUID],
        expenses: [LedgerExpense],
        settlementPayments: [LedgerSettlementPayment],
        currencyScale: Int
    ) throws -> [ParticipantBalance] {
        try MoneyMath.validateScale(currencyScale)

        if participantIDs.isEmpty {
            guard expenses.isEmpty, settlementPayments.isEmpty else {
                throw SettlementEngineError.emptyParticipantSet
            }
            return []
        }

        var balancesByParticipant: [UUID: Int64] = [:]

        for participantID in participantIDs {
            guard balancesByParticipant[participantID] == nil else {
                throw SettlementEngineError.duplicateParticipant(participantID)
            }
            balancesByParticipant[participantID] = 0
        }

        for expense in expenses {
            let expenseUnits = MoneyMath.minorUnits(expense.amount, scale: currencyScale)
            guard expenseUnits > 0 else {
                throw SettlementEngineError.invalidAmount
            }

            guard balancesByParticipant[expense.payerID] != nil else {
                throw SettlementEngineError.unknownParticipant(expense.payerID)
            }

            let allocations = try ExpenseAllocationService.validatedExactAllocations(
                amount: expense.amount,
                allocations: expense.allocations,
                currencyScale: currencyScale
            )

            balancesByParticipant[expense.payerID, default: 0] += expenseUnits

            for allocation in allocations {
                guard balancesByParticipant[allocation.participantID] != nil else {
                    throw SettlementEngineError.unknownParticipant(allocation.participantID)
                }

                let allocationUnits = MoneyMath.minorUnits(allocation.amount, scale: currencyScale)
                balancesByParticipant[allocation.participantID, default: 0] -= allocationUnits
            }
        }

        for payment in settlementPayments {
            guard payment.fromParticipantID != payment.toParticipantID else {
                throw SettlementEngineError.sameSettlementEndpoint
            }

            guard balancesByParticipant[payment.fromParticipantID] != nil else {
                throw SettlementEngineError.unknownParticipant(payment.fromParticipantID)
            }

            guard balancesByParticipant[payment.toParticipantID] != nil else {
                throw SettlementEngineError.unknownParticipant(payment.toParticipantID)
            }

            let paymentUnits = MoneyMath.minorUnits(payment.amount, scale: currencyScale)
            guard paymentUnits > 0 else {
                throw SettlementEngineError.invalidAmount
            }

            // A debtor paying a creditor moves both balances toward zero.
            balancesByParticipant[payment.fromParticipantID, default: 0] += paymentUnits
            balancesByParticipant[payment.toParticipantID, default: 0] -= paymentUnits
        }

        let ledgerTotal = balancesByParticipant.values.reduce(Int64(0), +)
        guard ledgerTotal == 0 else {
            throw SettlementEngineError.unbalancedLedger(ledgerTotal)
        }

        return participantIDs.map { participantID in
            ParticipantBalance(
                participantID: participantID,
                amount: MoneyMath.decimal(
                    fromMinorUnits: balancesByParticipant[participantID, default: 0],
                    scale: currencyScale
                )
            )
        }
    }

    static func settlementPlan(
        balances: [ParticipantBalance],
        currencyScale: Int
    ) throws -> [SettlementTransfer] {
        try MoneyMath.validateScale(currencyScale)

        var seenParticipantIDs = Set<UUID>()
        var debtors: [Account] = []
        var creditors: [Account] = []
        var totalUnits: Int64 = 0

        for balance in balances {
            guard seenParticipantIDs.insert(balance.participantID).inserted else {
                throw SettlementEngineError.duplicateParticipant(balance.participantID)
            }

            let units = MoneyMath.minorUnits(balance.amount, scale: currencyScale)
            totalUnits += units

            if units < 0 {
                debtors.append(Account(participantID: balance.participantID, units: -units))
            } else if units > 0 {
                creditors.append(Account(participantID: balance.participantID, units: units))
            }
        }

        guard totalUnits == 0 else {
            throw SettlementEngineError.unbalancedLedger(totalUnits)
        }

        var transfers: [SettlementTransfer] = []
        sortAccounts(&debtors)
        sortAccounts(&creditors)

        // Exact balance matches are removed first. This avoids unnecessary split
        // payments in common cases while keeping the algorithm deterministic.
        while let match = exactMatch(debtors: debtors, creditors: creditors) {
            let debtor = debtors.remove(at: match.debtorIndex)
            let creditor = creditors.remove(at: match.creditorIndex)

            transfers.append(
                SettlementTransfer(
                    fromParticipantID: debtor.participantID,
                    toParticipantID: creditor.participantID,
                    amount: MoneyMath.decimal(fromMinorUnits: debtor.units, scale: currencyScale)
                )
            )
        }

        // Net remaining debtors against creditors. Every transfer fully settles
        // at least one side, so the resulting plan never contains redundant loops.
        while !debtors.isEmpty, !creditors.isEmpty {
            sortAccounts(&debtors)
            sortAccounts(&creditors)

            var debtor = debtors.removeFirst()
            var creditor = creditors.removeFirst()
            let transferUnits = min(debtor.units, creditor.units)

            transfers.append(
                SettlementTransfer(
                    fromParticipantID: debtor.participantID,
                    toParticipantID: creditor.participantID,
                    amount: MoneyMath.decimal(fromMinorUnits: transferUnits, scale: currencyScale)
                )
            )

            debtor.units -= transferUnits
            creditor.units -= transferUnits

            if debtor.units > 0 {
                debtors.append(debtor)
            }

            if creditor.units > 0 {
                creditors.append(creditor)
            }
        }

        guard debtors.isEmpty, creditors.isEmpty else {
            let unresolvedUnits = debtors.reduce(Int64(0)) { $0 - $1.units }
                + creditors.reduce(Int64(0)) { $0 + $1.units }
            throw SettlementEngineError.unbalancedLedger(unresolvedUnits)
        }

        return transfers
    }

    private struct Account {
        let participantID: UUID
        var units: Int64
    }

    private struct ExactMatch {
        let debtorIndex: Int
        let creditorIndex: Int
    }

    private static func exactMatch(
        debtors: [Account],
        creditors: [Account]
    ) -> ExactMatch? {
        for (debtorIndex, debtor) in debtors.enumerated() {
            if let creditorIndex = creditors.firstIndex(where: { $0.units == debtor.units }) {
                return ExactMatch(debtorIndex: debtorIndex, creditorIndex: creditorIndex)
            }
        }
        return nil
    }

    private static func sortAccounts(_ accounts: inout [Account]) {
        accounts.sort {
            if $0.units != $1.units {
                return $0.units > $1.units
            }
            return $0.participantID.uuidString < $1.participantID.uuidString
        }
    }
}
