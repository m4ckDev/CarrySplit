import Combine
import Foundation

enum SplitUIError: LocalizedError, Equatable {
    case splitNotFound
    case expenseNotFound
    case emptySplitName
    case emptyParticipantName
    case duplicateParticipantName
    case emptyExpenseTitle
    case invalidAmount
    case invalidParticipant
    case invalidPayer
    case invalidSettlement

    var errorDescription: String? {
        switch self {
        case .splitNotFound:
            return "This split could not be found."
        case .expenseNotFound:
            return "This expense could not be found."
        case .emptySplitName:
            return "Enter a name for the split."
        case .emptyParticipantName:
            return "Enter a participant name."
        case .duplicateParticipantName:
            return "That participant is already in this split."
        case .emptyExpenseTitle:
            return "Enter a name for the expense."
        case .invalidAmount:
            return "Enter an amount greater than zero."
        case .invalidParticipant:
            return "Select at least one valid participant."
        case .invalidPayer:
            return "Select who paid for this expense."
        case .invalidSettlement:
            return "That settlement is no longer valid. Refresh the settlement plan and try again."
        }
    }
}

@MainActor
final class SplitsViewModel: ObservableObject {
    @Published private(set) var splits: [SplitSession] = []

    @discardableResult
    func createSplit(name: String, currency: CurrencyOption) throws -> UUID {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw SplitUIError.emptySplitName
        }

        let split = SplitSession(
            name: trimmedName,
            currencyCode: currency.code,
            currencyFractionDigits: currency.fractionDigits
        )
        splits.append(split)
        return split.id
    }

    @discardableResult
    func addParticipant(name: String, to splitID: UUID) throws -> UUID {
        guard let splitIndex = splitIndex(for: splitID) else {
            throw SplitUIError.splitNotFound
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw SplitUIError.emptyParticipantName
        }

        let duplicateExists = splits[splitIndex].participants.contains {
            $0.name.compare(trimmedName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
        guard !duplicateExists else {
            throw SplitUIError.duplicateParticipantName
        }

        let participant = ParticipantEntry(
            name: trimmedName,
            sortOrder: splits[splitIndex].participants.count
        )
        splits[splitIndex].participants.append(participant)
        return participant.id
    }

    func saveExpense(
        to splitID: UUID,
        expenseID: UUID? = nil,
        title: String,
        amount: Decimal,
        payerID: UUID,
        splitMethod: SplitMethod,
        participantIDs: [UUID],
        exactAmounts: [UUID: Decimal] = [:],
        expenseDate: Date = .now
    ) throws {
        guard let splitIndex = splitIndex(for: splitID) else {
            throw SplitUIError.splitNotFound
        }

        let split = splits[splitIndex]
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw SplitUIError.emptyExpenseTitle
        }

        guard MoneyMath.minorUnits(amount, scale: split.currencyFractionDigits) > 0 else {
            throw SplitUIError.invalidAmount
        }

        let validParticipantIDs = Set(split.participants.map(\.id))
        guard validParticipantIDs.contains(payerID) else {
            throw SplitUIError.invalidPayer
        }

        let orderedParticipantIDs = split.participants
            .filter { participantIDs.contains($0.id) }
            .map(\.id)

        guard !orderedParticipantIDs.isEmpty,
              orderedParticipantIDs.count == Set(participantIDs).count,
              orderedParticipantIDs.allSatisfy(validParticipantIDs.contains) else {
            throw SplitUIError.invalidParticipant
        }

        let allocations: [LedgerAllocation]
        switch splitMethod {
        case .equal:
            allocations = try ExpenseAllocationService.equalAllocations(
                amount: amount,
                participantIDs: orderedParticipantIDs,
                currencyScale: split.currencyFractionDigits
            )
        case .exact:
            let exactAllocations = orderedParticipantIDs.map { participantID in
                LedgerAllocation(
                    participantID: participantID,
                    amount: exactAmounts[participantID] ?? .zero
                )
            }
            allocations = try ExpenseAllocationService.validatedExactAllocations(
                amount: amount,
                allocations: exactAllocations,
                currencyScale: split.currencyFractionDigits
            )
        }

        let expense = ExpenseEntry(
            id: expenseID ?? UUID(),
            title: trimmedTitle,
            amount: amount,
            payerID: payerID,
            splitMethod: splitMethod,
            expenseDate: expenseDate,
            allocations: allocations
        )

        if let expenseID {
            guard let expenseIndex = splits[splitIndex].expenses.firstIndex(where: { $0.id == expenseID }) else {
                throw SplitUIError.expenseNotFound
            }
            splits[splitIndex].expenses[expenseIndex] = expense
        } else {
            splits[splitIndex].expenses.append(expense)
        }
    }

    func balances(for splitID: UUID) throws -> [ParticipantBalance] {
        guard let split = split(withID: splitID) else {
            throw SplitUIError.splitNotFound
        }

        return try SettlementService.balances(
            participantIDs: split.participants.map(\.id),
            expenses: split.ledgerExpenses,
            settlementPayments: split.ledgerSettlementPayments,
            currencyScale: split.currencyFractionDigits
        )
    }

    func settlementPlan(for splitID: UUID) throws -> [SettlementTransfer] {
        guard let split = split(withID: splitID) else {
            throw SplitUIError.splitNotFound
        }

        return try SettlementService.settlementPlan(
            balances: balances(for: splitID),
            currencyScale: split.currencyFractionDigits
        )
    }

    func markSettlementPaid(_ transfer: SettlementTransfer, in splitID: UUID) throws {
        guard let splitIndex = splitIndex(for: splitID) else {
            throw SplitUIError.splitNotFound
        }

        let currentPlan = try settlementPlan(for: splitID)
        guard currentPlan.contains(transfer) else {
            throw SplitUIError.invalidSettlement
        }

        splits[splitIndex].settlementPayments.append(
            SettlementEntry(
                fromParticipantID: transfer.fromParticipantID,
                toParticipantID: transfer.toParticipantID,
                amount: transfer.amount
            )
        )
    }

    func split(withID splitID: UUID) -> SplitSession? {
        splits.first { $0.id == splitID }
    }

    func expense(withID expenseID: UUID, in splitID: UUID) -> ExpenseEntry? {
        split(withID: splitID)?.expenses.first { $0.id == expenseID }
    }

    func participantName(for participantID: UUID, in splitID: UUID) -> String {
        split(withID: splitID)?.participants.first(where: { $0.id == participantID })?.name ?? "Unknown"
    }

    func formattedAmount(_ amount: Decimal, in splitID: UUID) -> String {
        guard let split = split(withID: splitID) else {
            return "\(amount)"
        }
        return CurrencyFormatter.string(from: amount, currencyCode: split.currencyCode)
    }

    private func splitIndex(for splitID: UUID) -> Int? {
        splits.firstIndex { $0.id == splitID }
    }
}
