import Foundation
import XCTest
@testable import CarrySplits

final class SettlementServiceTests: XCTestCase {
    func testEqualSplitDistributesRemainderAndPreservesTotal() throws {
        let people = [UUID(), UUID(), UUID()]

        let allocations = try ExpenseAllocationService.equalAllocations(
            amount: decimal("10.00"),
            participantIDs: people,
            currencyScale: 2
        )

        XCTAssertEqual(allocations.count, 3)
        XCTAssertEqual(allocations[0].amount, decimal("3.34"))
        XCTAssertEqual(allocations[1].amount, decimal("3.33"))
        XCTAssertEqual(allocations[2].amount, decimal("3.33"))
        XCTAssertEqual(MoneyMath.sum(allocations.map(\.amount)), decimal("10.00"))
    }

    func testEqualSplitSupportsZeroDecimalCurrency() throws {
        let people = [UUID(), UUID(), UUID()]

        let allocations = try ExpenseAllocationService.equalAllocations(
            amount: decimal("1000"),
            participantIDs: people,
            currencyScale: 0
        )

        XCTAssertEqual(allocations.map(\.amount), [decimal("334"), decimal("333"), decimal("333")])
        XCTAssertEqual(MoneyMath.sum(allocations.map(\.amount)), decimal("1000"))
    }

    func testExactSplitRejectsAllocationTotalMismatch() {
        let allocations = [
            LedgerAllocation(participantID: UUID(), amount: decimal("4.00")),
            LedgerAllocation(participantID: UUID(), amount: decimal("5.00"))
        ]

        XCTAssertThrowsError(
            try ExpenseAllocationService.validatedExactAllocations(
                amount: decimal("10.00"),
                allocations: allocations,
                currencyScale: 2
            )
        ) { error in
            XCTAssertEqual(
                error as? SettlementEngineError,
                .allocationTotalMismatch(expectedMinorUnits: 1000, actualMinorUnits: 900)
            )
        }
    }

    func testBalancesCarryForwardAcrossMultiplePayers() throws {
        let john = UUID()
        let sarah = UUID()
        let mike = UUID()
        let people = [john, sarah, mike]

        let dinnerAllocations = try ExpenseAllocationService.equalAllocations(
            amount: decimal("60.00"),
            participantIDs: people,
            currencyScale: 2
        )

        let parkingAllocations = try ExpenseAllocationService.equalAllocations(
            amount: decimal("30.00"),
            participantIDs: people,
            currencyScale: 2
        )

        let expenses = [
            LedgerExpense(
                id: UUID(),
                payerID: john,
                amount: decimal("60.00"),
                allocations: dinnerAllocations
            ),
            LedgerExpense(
                id: UUID(),
                payerID: sarah,
                amount: decimal("30.00"),
                allocations: parkingAllocations
            )
        ]

        let balances = try SettlementService.balances(
            participantIDs: people,
            expenses: expenses,
            settlementPayments: [],
            currencyScale: 2
        )

        XCTAssertEqual(balance(for: john, in: balances), decimal("30.00"))
        XCTAssertEqual(balance(for: sarah, in: balances), decimal("0.00"))
        XCTAssertEqual(balance(for: mike, in: balances), decimal("-30.00"))
        XCTAssertEqual(MoneyMath.sum(balances.map(\.amount)), decimal("0.00"))
    }

    func testCompletedSettlementMovesBalancesTowardZero() throws {
        let john = UUID()
        let mike = UUID()

        let expense = LedgerExpense(
            id: UUID(),
            payerID: john,
            amount: decimal("30.00"),
            allocations: [
                LedgerAllocation(participantID: john, amount: decimal("15.00")),
                LedgerAllocation(participantID: mike, amount: decimal("15.00"))
            ]
        )

        let payment = LedgerSettlementPayment(
            fromParticipantID: mike,
            toParticipantID: john,
            amount: decimal("10.00")
        )

        let balances = try SettlementService.balances(
            participantIDs: [john, mike],
            expenses: [expense],
            settlementPayments: [payment],
            currencyScale: 2
        )

        XCTAssertEqual(balance(for: john, in: balances), decimal("5.00"))
        XCTAssertEqual(balance(for: mike, in: balances), decimal("-5.00"))
    }

    func testSettlementPlanProducesExpectedTransfers() throws {
        let john = UUID()
        let sarah = UUID()
        let mike = UUID()

        let plan = try SettlementService.settlementPlan(
            balances: [
                ParticipantBalance(participantID: john, amount: decimal("42.50")),
                ParticipantBalance(participantID: sarah, amount: decimal("-17.50")),
                ParticipantBalance(participantID: mike, amount: decimal("-25.00"))
            ],
            currencyScale: 2
        )

        XCTAssertEqual(plan.count, 2)
        XCTAssertTrue(
            plan.contains(
                SettlementTransfer(
                    fromParticipantID: sarah,
                    toParticipantID: john,
                    amount: decimal("17.50")
                )
            )
        )
        XCTAssertTrue(
            plan.contains(
                SettlementTransfer(
                    fromParticipantID: mike,
                    toParticipantID: john,
                    amount: decimal("25.00")
                )
            )
        )
    }

    func testSettlementPlanPrioritizesExactBalanceMatches() throws {
        let debtorTen = UUID()
        let debtorFive = UUID()
        let creditorFive = UUID()
        let creditorTen = UUID()

        let plan = try SettlementService.settlementPlan(
            balances: [
                ParticipantBalance(participantID: debtorTen, amount: decimal("-10.00")),
                ParticipantBalance(participantID: debtorFive, amount: decimal("-5.00")),
                ParticipantBalance(participantID: creditorFive, amount: decimal("5.00")),
                ParticipantBalance(participantID: creditorTen, amount: decimal("10.00"))
            ],
            currencyScale: 2
        )

        XCTAssertEqual(plan.count, 2)
        XCTAssertTrue(
            plan.contains(
                SettlementTransfer(
                    fromParticipantID: debtorTen,
                    toParticipantID: creditorTen,
                    amount: decimal("10.00")
                )
            )
        )
        XCTAssertTrue(
            plan.contains(
                SettlementTransfer(
                    fromParticipantID: debtorFive,
                    toParticipantID: creditorFive,
                    amount: decimal("5.00")
                )
            )
        )
    }

    func testSettlementPlanRejectsUnbalancedInput() {
        XCTAssertThrowsError(
            try SettlementService.settlementPlan(
                balances: [
                    ParticipantBalance(participantID: UUID(), amount: decimal("10.00")),
                    ParticipantBalance(participantID: UUID(), amount: decimal("-9.00"))
                ],
                currencyScale: 2
            )
        ) { error in
            XCTAssertEqual(error as? SettlementEngineError, .unbalancedLedger(100))
        }
    }

    func testLedgerRejectsUnknownParticipant() throws {
        let john = UUID()
        let unknown = UUID()

        let expense = LedgerExpense(
            id: UUID(),
            payerID: john,
            amount: decimal("10.00"),
            allocations: [
                LedgerAllocation(participantID: john, amount: decimal("5.00")),
                LedgerAllocation(participantID: unknown, amount: decimal("5.00"))
            ]
        )

        XCTAssertThrowsError(
            try SettlementService.balances(
                participantIDs: [john],
                expenses: [expense],
                settlementPayments: [],
                currencyScale: 2
            )
        ) { error in
            XCTAssertEqual(error as? SettlementEngineError, .unknownParticipant(unknown))
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
