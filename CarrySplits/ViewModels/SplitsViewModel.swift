import Combine
import Foundation
import SwiftData

enum SplitUIError: LocalizedError, Equatable {
    case splitNotFound
    case participantNotFound
    case expenseNotFound
    case emptySplitName
    case emptyParticipantName
    case duplicateParticipantName
    case participantInUse
    case emptyExpenseTitle
    case invalidAmount
    case invalidParticipant
    case invalidPayer
    case invalidSettlement
    case persistenceUnavailable
    case persistenceFailure(String)

    var errorDescription: String? {
        switch self {
        case .splitNotFound:
            return "This split could not be found."
        case .participantNotFound:
            return "This participant could not be found."
        case .expenseNotFound:
            return "This expense could not be found."
        case .emptySplitName:
            return "Enter a name for the split."
        case .emptyParticipantName:
            return "Enter a participant name."
        case .duplicateParticipantName:
            return "That participant is already in this split."
        case .participantInUse:
            return "This person is referenced by an expense or settlement. Rename them instead, or remove the related history first."
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
        case .persistenceUnavailable:
            return "Carry Splits is not connected to its local data store."
        case .persistenceFailure(let message):
            return "Could not save Carry Splits data: \(message)"
        }
    }
}

@MainActor
final class SplitsViewModel: ObservableObject {
    @Published private(set) var splits: [SplitSession] = []
    @Published private(set) var persistenceErrorMessage: String?

    private var modelContext: ModelContext?

    var activeSplits: [SplitSession] {
        splits.filter { !$0.isArchived }
    }

    var archivedSplits: [SplitSession] {
        splits.filter(\.isArchived)
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext

        do {
            try reloadSplits(using: modelContext)
            persistenceErrorMessage = nil
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    func reloadFromPersistence() throws {
        let context = try requireContext()
        do {
            try reloadSplits(using: context)
            persistenceErrorMessage = nil
        } catch {
            let mapped = mapPersistenceError(error)
            persistenceErrorMessage = mapped.localizedDescription
            throw mapped
        }
    }

    @discardableResult
    func createSplit(name: String, currency: CurrencyOption) throws -> UUID {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw SplitUIError.emptySplitName
        }

        let context = try requireContext()
        let split = ExpenseSplit(
            name: trimmedName,
            currencyCode: currency.code,
            currencyFractionDigits: currency.fractionDigits
        )

        context.insert(split)
        try saveAndReload(context)
        return split.id
    }

    func renameSplit(_ splitID: UUID, to name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw SplitUIError.emptySplitName
        }

        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        split.name = trimmedName
        split.updatedAt = .now
        try saveAndReload(context)
    }

    func setSplitArchived(_ splitID: UUID, archived: Bool) throws {
        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        split.isArchived = archived
        split.updatedAt = .now
        try saveAndReload(context)
    }

    func deleteSplit(_ splitID: UUID) throws {
        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        context.delete(split)
        try saveAndReload(context)
    }

    @discardableResult
    func addParticipant(name: String, to splitID: UUID) throws -> UUID {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw SplitUIError.emptyParticipantName
        }

        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        try validateParticipantName(trimmedName, in: split, excluding: nil)

        let nextSortOrder = (split.participants.map(\.sortOrder).max() ?? -1) + 1
        let participant = Participant(
            name: trimmedName,
            sortOrder: nextSortOrder
        )

        context.insert(participant)
        split.participants.append(participant)
        split.updatedAt = .now
        try saveAndReload(context)
        return participant.id
    }

    func renameParticipant(_ participantID: UUID, in splitID: UUID, to name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw SplitUIError.emptyParticipantName
        }

        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        guard let participant = split.participants.first(where: { $0.id == participantID }) else {
            throw SplitUIError.participantNotFound
        }

        try validateParticipantName(trimmedName, in: split, excluding: participantID)
        participant.name = trimmedName
        split.updatedAt = .now
        try saveAndReload(context)
    }

    func deleteParticipant(_ participantID: UUID, from splitID: UUID) throws {
        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        guard let participant = split.participants.first(where: { $0.id == participantID }) else {
            throw SplitUIError.participantNotFound
        }

        let referencedByExpense = split.expenses.contains { expense in
            expense.payerID == participantID
                || expense.allocations.contains(where: { $0.participantID == participantID })
        }
        let referencedBySettlement = split.settlementPayments.contains { payment in
            payment.fromParticipantID == participantID || payment.toParticipantID == participantID
        }

        guard !referencedByExpense, !referencedBySettlement else {
            throw SplitUIError.participantInUse
        }

        split.participants.removeAll { $0.id == participantID }
        context.delete(participant)

        for (index, remainingParticipant) in split.participants
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .enumerated() {
            remainingParticipant.sortOrder = index
        }

        split.updatedAt = .now
        try saveAndReload(context)
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
        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw SplitUIError.emptyExpenseTitle
        }

        let totalMinorUnits = MoneyMath.minorUnits(amount, scale: split.currencyFractionDigits)
        guard totalMinorUnits > 0 else {
            throw SplitUIError.invalidAmount
        }
        let normalizedAmount = MoneyMath.decimal(
            fromMinorUnits: totalMinorUnits,
            scale: split.currencyFractionDigits
        )

        let validParticipantIDs = Set(split.participants.map(\.id))
        guard validParticipantIDs.contains(payerID) else {
            throw SplitUIError.invalidPayer
        }

        let orderedParticipantIDs = split.participants
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .filter { participantIDs.contains($0.id) }
            .map(\.id)

        guard !orderedParticipantIDs.isEmpty,
              orderedParticipantIDs.count == Set(participantIDs).count,
              orderedParticipantIDs.allSatisfy(validParticipantIDs.contains) else {
            throw SplitUIError.invalidParticipant
        }

        let ledgerAllocations: [LedgerAllocation]
        switch splitMethod {
        case .equal:
            ledgerAllocations = try ExpenseAllocationService.equalAllocations(
                amount: normalizedAmount,
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
            ledgerAllocations = try ExpenseAllocationService.validatedExactAllocations(
                amount: normalizedAmount,
                allocations: exactAllocations,
                currencyScale: split.currencyFractionDigits
            )
        }

        let allocationModels = ledgerAllocations.enumerated().map { index, allocation in
            ExpenseAllocation(
                participantID: allocation.participantID,
                amount: allocation.amount,
                sortOrder: index
            )
        }
        allocationModels.forEach(context.insert)

        if let expenseID {
            guard let expense = split.expenses.first(where: { $0.id == expenseID }) else {
                throw SplitUIError.expenseNotFound
            }

            let oldAllocations = expense.allocations
            expense.allocations = []
            oldAllocations.forEach(context.delete)

            expense.title = trimmedTitle
            expense.amount = normalizedAmount
            expense.payerID = payerID
            expense.splitMethod = splitMethod
            expense.expenseDate = expenseDate
            expense.updatedAt = .now
            expense.allocations = allocationModels
        } else {
            let expense = Expense(
                title: trimmedTitle,
                amount: normalizedAmount,
                payerID: payerID,
                splitMethod: splitMethod,
                expenseDate: expenseDate,
                allocations: allocationModels
            )
            context.insert(expense)
            split.expenses.append(expense)
        }

        split.updatedAt = .now
        try saveAndReload(context)
    }

    func deleteExpense(_ expenseID: UUID, from splitID: UUID) throws {
        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        guard let expense = split.expenses.first(where: { $0.id == expenseID }) else {
            throw SplitUIError.expenseNotFound
        }

        split.expenses.removeAll { $0.id == expenseID }
        context.delete(expense)
        split.updatedAt = .now
        try saveAndReload(context)
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
        let currentPlan = try settlementPlan(for: splitID)
        guard currentPlan.contains(transfer) else {
            throw SplitUIError.invalidSettlement
        }

        let context = try requireContext()
        let split = try storedSplit(withID: splitID, in: context)
        let payment = SettlementPayment(
            fromParticipantID: transfer.fromParticipantID,
            toParticipantID: transfer.toParticipantID,
            amount: transfer.amount
        )

        context.insert(payment)
        split.settlementPayments.append(payment)
        split.updatedAt = .now
        try saveAndReload(context)
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

    private func requireContext() throws -> ModelContext {
        guard let modelContext else {
            throw SplitUIError.persistenceUnavailable
        }
        return modelContext
    }

    private func storedSplit(withID splitID: UUID, in context: ModelContext) throws -> ExpenseSplit {
        do {
            let descriptor = FetchDescriptor<ExpenseSplit>()
            guard let split = try context.fetch(descriptor).first(where: { $0.id == splitID }) else {
                throw SplitUIError.splitNotFound
            }
            return split
        } catch let error as SplitUIError {
            throw error
        } catch {
            throw mapPersistenceError(error)
        }
    }

    private func validateParticipantName(
        _ name: String,
        in split: ExpenseSplit,
        excluding participantID: UUID?
    ) throws {
        let duplicateExists = split.participants.contains { participant in
            participant.id != participantID
                && participant.name.compare(
                    name,
                    options: [.caseInsensitive, .diacriticInsensitive]
                ) == .orderedSame
        }

        guard !duplicateExists else {
            throw SplitUIError.duplicateParticipantName
        }
    }

    private func saveAndReload(_ context: ModelContext) throws {
        do {
            try context.save()
            try reloadSplits(using: context)
            persistenceErrorMessage = nil
        } catch {
            let mapped = mapPersistenceError(error)
            persistenceErrorMessage = mapped.localizedDescription
            throw mapped
        }
    }

    private func reloadSplits(using context: ModelContext) throws {
        let descriptor = FetchDescriptor<ExpenseSplit>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        splits = try context.fetch(descriptor).map(SplitSession.init(model:))
    }

    private func mapPersistenceError(_ error: Error) -> SplitUIError {
        if let splitError = error as? SplitUIError {
            return splitError
        }
        return .persistenceFailure(error.localizedDescription)
    }
}
