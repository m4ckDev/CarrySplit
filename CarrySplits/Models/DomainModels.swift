import Foundation
import SwiftData

enum SplitMethod: String, Codable, CaseIterable, Identifiable {
    case equal
    case exact

    var id: Self { self }
}

@Model
final class ExpenseSplit {
    @Attribute(.unique) var id: UUID
    var name: String
    var currencyCode: String
    var currencyFractionDigits: Int
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    @Relationship(deleteRule: .cascade)
    var participants: [Participant] = []

    @Relationship(deleteRule: .cascade)
    var expenses: [Expense] = []

    @Relationship(deleteRule: .cascade)
    var settlementPayments: [SettlementPayment] = []

    init(
        id: UUID = UUID(),
        name: String,
        currencyCode: String,
        currencyFractionDigits: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.currencyCode = currencyCode.uppercased()
        self.currencyFractionDigits = currencyFractionDigits
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }
}

@Model
final class Participant {
    @Attribute(.unique) var id: UUID
    var name: String
    var sortOrder: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        sortOrder: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}

@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Decimal
    var payerID: UUID
    var splitMethod: SplitMethod
    var expenseDate: Date
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var allocations: [ExpenseAllocation] = []

    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        payerID: UUID,
        splitMethod: SplitMethod,
        expenseDate: Date = .now,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        allocations: [ExpenseAllocation] = []
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.payerID = payerID
        self.splitMethod = splitMethod
        self.expenseDate = expenseDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.allocations = allocations
    }
}

@Model
final class ExpenseAllocation {
    @Attribute(.unique) var id: UUID
    var participantID: UUID
    var amount: Decimal
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        participantID: UUID,
        amount: Decimal,
        sortOrder: Int
    ) {
        self.id = id
        self.participantID = participantID
        self.amount = amount
        self.sortOrder = sortOrder
    }
}

@Model
final class SettlementPayment {
    @Attribute(.unique) var id: UUID
    var fromParticipantID: UUID
    var toParticipantID: UUID
    var amount: Decimal
    var settledAt: Date

    init(
        id: UUID = UUID(),
        fromParticipantID: UUID,
        toParticipantID: UUID,
        amount: Decimal,
        settledAt: Date = .now
    ) {
        self.id = id
        self.fromParticipantID = fromParticipantID
        self.toParticipantID = toParticipantID
        self.amount = amount
        self.settledAt = settledAt
    }
}
