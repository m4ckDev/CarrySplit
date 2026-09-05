import SwiftData
import SwiftUI

@main
struct CarrySplitsApp: App {
    var body: some Scene {
        WindowGroup {
            SplitsView()
        }
        .modelContainer(
            for: [
                ExpenseSplit.self,
                Participant.self,
                Expense.self,
                ExpenseAllocation.self,
                SettlementPayment.self
            ]
        )
    }
}
