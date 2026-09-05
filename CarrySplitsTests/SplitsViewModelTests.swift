import Foundation
import XCTest
@testable import CarrySplits

@MainActor
final class SplitsViewModelTests: XCTestCase {
    func testCompleteEqualSplitWorkflowSettlesToZero() throws {
        let viewModel = SplitsViewModel()
        let splitID = try viewModel.createSplit(
            name: "Dinner",
            currency: CurrencyOption(code: "USD", name: "US Dollar", fractionDigits: 2)
        )

        let john = try viewModel.addParticipant(name: "John", to: splitID)
        let sarah = try viewModel.addParticipant(name: "Sarah", to: splitID)

        try viewModel.saveExpense(
            to: splitID,
            title: "Dinner",
            amount: decimal("60.00"),
            payerID: john,
            splitMethod: .equal,
            participantIDs: [john, sarah]
        )

        let balances = try viewModel.balances(for: splitID)
        XCTAssertEqual(balance(for: john, in: balances), decimal("30.00"))
        XCTAssertEqual(balance(for: sarah, in: balances), decimal("-30.00"))

        let plan = try viewModel.settlementPlan(for: splitID)
        XCTAssertEqual(plan.count, 1)
        XCTAssertEqual(plan[0].fromParticipantID, sarah)
        XCTAssertEqual(plan[0].toParticipantID, john)
        XCTAssertEqual(plan[0].amount, decimal("30.00"))

        try viewModel.markSettlementPaid(plan[0], in: splitID)

        XCTAssertTrue(try viewModel.settlementPlan(for: splitID).isEmpty)
        XCTAssertEqual(viewModel.split(withID: splitID)?.settlementPayments.count, 1)
    }

    func testEditingExpenseRecalculatesBalances() throws {
        let viewModel = SplitsViewModel()
        let splitID = try viewModel.createSplit(
            name: "Trip",
            currency: CurrencyOption(code: "USD", name: "US Dollar", fractionDigits: 2)
        )

        let alex = try viewModel.addParticipant(name: "Alex", to: splitID)
        let sam = try viewModel.addParticipant(name: "Sam", to: splitID)

        try viewModel.saveExpense(
            to: splitID,
            title: "Fuel",
            amount: decimal("40.00"),
            payerID: alex,
            splitMethod: .equal,
            participantIDs: [alex, sam]
        )

        let expenseID = try XCTUnwrap(viewModel.split(withID: splitID)?.expenses.first?.id)

        try viewModel.saveExpense(
            to: splitID,
            expenseID: expenseID,
            title: "Fuel",
            amount: decimal("60.00"),
            payerID: alex,
            splitMethod: .equal,
            participantIDs: [alex, sam]
        )

        let balances = try viewModel.balances(for: splitID)
        XCTAssertEqual(balance(for: alex, in: balances), decimal("30.00"))
        XCTAssertEqual(balance(for: sam, in: balances), decimal("-30.00"))
        XCTAssertEqual(viewModel.split(withID: splitID)?.expenses.count, 1)
    }

    func testDuplicateParticipantNameIsRejectedCaseInsensitively() throws {
        let viewModel = SplitsViewModel()
        let splitID = try viewModel.createSplit(
            name: "Weekend",
            currency: CurrencyOption(code: "USD", name: "US Dollar", fractionDigits: 2)
        )

        _ = try viewModel.addParticipant(name: "Mike", to: splitID)

        XCTAssertThrowsError(try viewModel.addParticipant(name: "mike", to: splitID)) { error in
            XCTAssertEqual(error as? SplitUIError, .duplicateParticipantName)
        }
    }

    private func decimal(_ value: String) -> Decimal {
        guard let decimal = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) else {
            XCTFail("Invalid Decimal test fixture: \(value)")
            return .zero
        }
        return decimal
    }

    private func balance(for participantID: UUID, in balances: [ParticipantBalance]) -> Decimal? {
        balances.first(where: { $0.participantID == participantID })?.amount
    }
}
