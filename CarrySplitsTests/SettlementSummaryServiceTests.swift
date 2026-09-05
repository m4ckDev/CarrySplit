import Foundation
import XCTest
@testable import CarrySplits

final class SettlementSummaryServiceTests: XCTestCase {
    func testSummaryListsCurrentSettlementTransfers() {
        let john = UUID()
        let sarah = UUID()
        let mike = UUID()

        let split = SplitSession(
            name: "Tokyo Trip",
            currencyCode: "USD",
            currencyFractionDigits: 2,
            participants: [
                ParticipantEntry(id: john, name: "John", sortOrder: 0),
                ParticipantEntry(id: sarah, name: "Sarah", sortOrder: 1),
                ParticipantEntry(id: mike, name: "Mike", sortOrder: 2)
            ],
            expenses: [
                ExpenseEntry(
                    title: "Dinner",
                    amount: decimal("60.00"),
                    payerID: john,
                    splitMethod: .equal,
                    allocations: []
                )
            ]
        )

        let plan = [
            SettlementTransfer(
                fromParticipantID: sarah,
                toParticipantID: john,
                amount: decimal("17.50")
            ),
            SettlementTransfer(
                fromParticipantID: mike,
                toParticipantID: john,
                amount: decimal("25.00")
            )
        ]

        let summary = SettlementSummaryService.summary(
            for: split,
            plan: plan,
            locale: Locale(identifier: "en_US")
        )

        XCTAssertEqual(
            summary,
            "Carry Splits — Tokyo Trip\n\nSarah → John: $17.50\nMike → John: $25.00\n\nSettlement plan from Carry Splits."
        )
    }

    func testSummaryReportsAllSettled() {
        let participant = UUID()
        let split = SplitSession(
            name: "Dinner",
            currencyCode: "USD",
            currencyFractionDigits: 2,
            participants: [
                ParticipantEntry(id: participant, name: "Alex", sortOrder: 0)
            ],
            expenses: [
                ExpenseEntry(
                    title: "Dinner",
                    amount: decimal("20.00"),
                    payerID: participant,
                    splitMethod: .equal,
                    allocations: []
                )
            ]
        )

        let summary = SettlementSummaryService.summary(
            for: split,
            plan: [],
            locale: Locale(identifier: "en_US")
        )

        XCTAssertTrue(summary.contains("All settled."))
    }

    func testSummaryReportsNothingToSettleWithoutExpenses() {
        let split = SplitSession(
            name: "Weekend",
            currencyCode: "JPY",
            currencyFractionDigits: 0
        )

        let summary = SettlementSummaryService.summary(
            for: split,
            plan: [],
            locale: Locale(identifier: "ja_JP")
        )

        XCTAssertTrue(summary.contains("Nothing to settle yet."))
    }

    private func decimal(_ value: String) -> Decimal {
        guard let decimal = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) else {
            XCTFail("Invalid Decimal test fixture: \(value)")
            return .zero
        }
        return decimal
    }
}
