import Foundation

enum SplitLedgerAdapter {
    static func participantIDs(for split: ExpenseSplit) -> [UUID] {
        split.participants
            .sorted(by: participantSort)
            .map(\.id)
    }

    static func expenses(for split: ExpenseSplit) -> [LedgerExpense] {
        split.expenses.map { expense in
            LedgerExpense(
                id: expense.id,
                payerID: expense.payerID,
                amount: expense.amount,
                allocations: expense.allocations
                    .sorted { lhs, rhs in
                        if lhs.sortOrder != rhs.sortOrder {
                            return lhs.sortOrder < rhs.sortOrder
                        }
                        return lhs.id.uuidString < rhs.id.uuidString
                    }
                    .map {
                        LedgerAllocation(
                            participantID: $0.participantID,
                            amount: $0.amount
                        )
                    }
            )
        }
    }

    static func settlementPayments(for split: ExpenseSplit) -> [LedgerSettlementPayment] {
        split.settlementPayments.map {
            LedgerSettlementPayment(
                fromParticipantID: $0.fromParticipantID,
                toParticipantID: $0.toParticipantID,
                amount: $0.amount
            )
        }
    }

    static func balances(for split: ExpenseSplit) throws -> [ParticipantBalance] {
        try SettlementService.balances(
            participantIDs: participantIDs(for: split),
            expenses: expenses(for: split),
            settlementPayments: settlementPayments(for: split),
            currencyScale: split.currencyFractionDigits
        )
    }

    static func settlementPlan(for split: ExpenseSplit) throws -> [SettlementTransfer] {
        try SettlementService.settlementPlan(
            balances: balances(for: split),
            currencyScale: split.currencyFractionDigits
        )
    }

    private static func participantSort(_ lhs: Participant, _ rhs: Participant) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        if lhs.createdAt != rhs.createdAt {
            return lhs.createdAt < rhs.createdAt
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}
