import Foundation

struct LedgerAllocation: Equatable {
    let participantID: UUID
    let amount: Decimal
}

struct LedgerExpense: Equatable {
    let id: UUID
    let payerID: UUID
    let amount: Decimal
    let allocations: [LedgerAllocation]
}

struct LedgerSettlementPayment: Equatable {
    let fromParticipantID: UUID
    let toParticipantID: UUID
    let amount: Decimal
}

struct ParticipantBalance: Equatable {
    let participantID: UUID
    let amount: Decimal
}

struct SettlementTransfer: Equatable {
    let fromParticipantID: UUID
    let toParticipantID: UUID
    let amount: Decimal
}

enum SettlementEngineError: Error, Equatable {
    case invalidCurrencyScale(Int)
    case emptyParticipantSet
    case duplicateParticipant(UUID)
    case invalidAmount
    case duplicateAllocation(UUID)
    case unknownParticipant(UUID)
    case allocationTotalMismatch(expectedMinorUnits: Int64, actualMinorUnits: Int64)
    case sameSettlementEndpoint
    case unbalancedLedger(Int64)
}

extension SettlementEngineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCurrencyScale(let scale):
            return "Unsupported currency precision: \(scale) fraction digits."
        case .emptyParticipantSet:
            return "At least one participant is required."
        case .duplicateParticipant:
            return "A participant appears more than once."
        case .invalidAmount:
            return "Amounts must be greater than zero."
        case .duplicateAllocation:
            return "A participant appears more than once in an expense allocation."
        case .unknownParticipant:
            return "The ledger references a participant who is not part of this split."
        case .allocationTotalMismatch:
            return "Expense allocations do not equal the expense total."
        case .sameSettlementEndpoint:
            return "A settlement payment cannot be sent to the same participant."
        case .unbalancedLedger:
            return "The ledger is not balanced."
        }
    }
}
