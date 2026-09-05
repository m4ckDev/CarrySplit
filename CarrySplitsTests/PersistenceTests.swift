import Foundation
import SwiftData
import XCTest
@testable import CarrySplits

@MainActor
final class PersistenceTests: XCTestCase {
    func testCompleteLedgerReloadsIntoFreshModelContext() throws {
        let container = try makeContainer()
        let firstViewModel = configuredViewModel(context: ModelContext(container))

        let splitID = try firstViewModel.createSplit(
            name: "Tokyo Trip",
            currency: CurrencyOption(code: "JPY", name: "Japanese Yen", fractionDigits: 0)
        )
        let john = try firstViewModel.addParticipant(name: "John", to: splitID)
        let sarah = try firstViewModel.addParticipant(name: "Sarah", to: splitID)

        try firstViewModel.saveExpense(
            to: splitID,
            title: "Dinner",
            amount: decimal("6000"),
            payerID: john,
            splitMethod: .equal,
            participantIDs: [john, sarah]
        )

        let plan = try firstViewModel.settlementPlan(for: splitID)
        XCTAssertEqual(plan.count, 1)
        try firstViewModel.markSettlementPaid(plan[0], in: splitID)

        let secondViewModel = configuredViewModel(context: ModelContext(container))
        let reloaded = try XCTUnwrap(secondViewModel.split(withID: splitID))

        XCTAssertEqual(reloaded.name, "Tokyo Trip")
        XCTAssertEqual(reloaded.currencyCode, "JPY")
        XCTAssertEqual(reloaded.currencyFractionDigits, 0)
        XCTAssertEqual(reloaded.participants.count, 2)
        XCTAssertEqual(reloaded.expenses.count, 1)
        XCTAssertEqual(reloaded.settlementPayments.count, 1)
        XCTAssertTrue(try secondViewModel.settlementPlan(for: splitID).isEmpty)
    }

    func testRenameArchiveAndParticipantRenamePersistAcrossReload() throws {
        let container = try makeContainer()
        let firstViewModel = configuredViewModel(context: ModelContext(container))

        let splitID = try firstViewModel.createSplit(
            name: "Weekend",
            currency: CurrencyOption(code: "USD", name: "US Dollar", fractionDigits: 2)
        )
        let participantID = try firstViewModel.addParticipant(name: "Mike", to: splitID)

        try firstViewModel.renameSplit(splitID, to: "Beach Weekend")
        try firstViewModel.renameParticipant(participantID, in: splitID, to: "Michael")
        try firstViewModel.setSplitArchived(splitID, archived: true)

        let secondViewModel = configuredViewModel(context: ModelContext(container))
        let reloaded = try XCTUnwrap(secondViewModel.split(withID: splitID))

        XCTAssertEqual(reloaded.name, "Beach Weekend")
        XCTAssertTrue(reloaded.isArchived)
        XCTAssertEqual(reloaded.participants.first?.name, "Michael")
        XCTAssertTrue(secondViewModel.activeSplits.isEmpty)
        XCTAssertEqual(secondViewModel.archivedSplits.map(\.id), [splitID])
    }

    func testParticipantReferencedByExpenseCannotBeDeletedUntilExpenseIsRemoved() throws {
        let container = try makeContainer()
        let viewModel = configuredViewModel(context: ModelContext(container))

        let splitID = try viewModel.createSplit(
            name: "Dinner",
            currency: CurrencyOption(code: "USD", name: "US Dollar", fractionDigits: 2)
        )
        let john = try viewModel.addParticipant(name: "John", to: splitID)
        let sarah = try viewModel.addParticipant(name: "Sarah", to: splitID)

        try viewModel.saveExpense(
            to: splitID,
            title: "Dinner",
            amount: decimal("40.00"),
            payerID: john,
            splitMethod: .equal,
            participantIDs: [john, sarah]
        )

        XCTAssertThrowsError(try viewModel.deleteParticipant(sarah, from: splitID)) { error in
            XCTAssertEqual(error as? SplitUIError, .participantInUse)
        }

        let expenseID = try XCTUnwrap(viewModel.split(withID: splitID)?.expenses.first?.id)
        try viewModel.deleteExpense(expenseID, from: splitID)
        try viewModel.deleteParticipant(sarah, from: splitID)

        let reloadedViewModel = configuredViewModel(context: ModelContext(container))
        XCTAssertEqual(reloadedViewModel.split(withID: splitID)?.participants.map(\.id), [john])
        XCTAssertTrue(reloadedViewModel.split(withID: splitID)?.expenses.isEmpty == true)
    }

    func testDeletingSplitRemovesItFromFreshContext() throws {
        let container = try makeContainer()
        let firstViewModel = configuredViewModel(context: ModelContext(container))

        let splitID = try firstViewModel.createSplit(
            name: "Temporary",
            currency: CurrencyOption(code: "USD", name: "US Dollar", fractionDigits: 2)
        )
        _ = try firstViewModel.addParticipant(name: "Alex", to: splitID)

        try firstViewModel.deleteSplit(splitID)

        let secondViewModel = configuredViewModel(context: ModelContext(container))
        XCTAssertNil(secondViewModel.split(withID: splitID))
        XCTAssertTrue(secondViewModel.splits.isEmpty)
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            ExpenseSplit.self,
            Participant.self,
            Expense.self,
            ExpenseAllocation.self,
            SettlementPayment.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private func configuredViewModel(context: ModelContext) -> SplitsViewModel {
        let viewModel = SplitsViewModel()
        viewModel.configure(modelContext: context)
        return viewModel
    }

    private func decimal(_ value: String) -> Decimal {
        guard let decimal = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) else {
            XCTFail("Invalid Decimal test fixture: \(value)")
            return .zero
        }
        return decimal
    }
}
