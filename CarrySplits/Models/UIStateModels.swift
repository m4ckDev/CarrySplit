import Foundation

struct SplitSession: Identifiable, Equatable {
    let id: UUID
    var name: String
    var currencyCode: String
    var currencyFractionDigits: Int
    var createdAt: Date
    var participants: [ParticipantEntry]
    var expenses: [ExpenseEntry]
    var settlementPayments: [SettlementEntry]

    init(
        id: UUID = UUID(),
        name: String,
        currencyCode: String,
        currencyFractionDigits: Int,
        createdAt: Date = .now,
        participants: [ParticipantEntry] = [],
        expenses: [ExpenseEntry] = [],
        settlementPayments: [SettlementEntry] = []
    ) {
        self.id = id
        self.name = name
        self.currencyCode = currencyCode.uppercased()
        self.currencyFractionDigits = currencyFractionDigits
        self.createdAt = createdAt
        self.participants = participants
        self.expenses = expenses
        self.settlementPayments = settlementPayments
    }
}

struct ParticipantEntry: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var sortOrder: Int

    init(id: UUID = UUID(), name: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
    }
}

struct ExpenseEntry: Identifiable, Equatable {
    let id: UUID
    var title: String
    var amount: Decimal
    var payerID: UUID
    var splitMethod: SplitMethod
    var expenseDate: Date
    var allocations: [LedgerAllocation]

    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        payerID: UUID,
        splitMethod: SplitMethod,
        expenseDate: Date = .now,
        allocations: [LedgerAllocation]
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.payerID = payerID
        self.splitMethod = splitMethod
        self.expenseDate = expenseDate
        self.allocations = allocations
    }
}

struct SettlementEntry: Identifiable, Equatable {
    let id: UUID
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

extension SplitSession {
    var ledgerExpenses: [LedgerExpense] {
        expenses.map {
            LedgerExpense(
                id: $0.id,
                payerID: $0.payerID,
                amount: $0.amount,
                allocations: $0.allocations
            )
        }
    }

    var ledgerSettlementPayments: [LedgerSettlementPayment] {
        settlementPayments.map {
            LedgerSettlementPayment(
                fromParticipantID: $0.fromParticipantID,
                toParticipantID: $0.toParticipantID,
                amount: $0.amount
            )
        }
    }
}
