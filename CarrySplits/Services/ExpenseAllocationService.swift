import Foundation

enum ExpenseAllocationService {
    static func equalAllocations(
        amount: Decimal,
        participantIDs: [UUID],
        currencyScale: Int
    ) throws -> [LedgerAllocation] {
        try MoneyMath.validateScale(currencyScale)

        guard !participantIDs.isEmpty else {
            throw SettlementEngineError.emptyParticipantSet
        }

        try validateUniqueParticipantIDs(participantIDs)

        let totalUnits = MoneyMath.minorUnits(amount, scale: currencyScale)
        guard totalUnits > 0 else {
            throw SettlementEngineError.invalidAmount
        }

        let participantCount = Int64(participantIDs.count)
        let baseUnits = totalUnits / participantCount
        let remainderUnits = totalUnits % participantCount

        return participantIDs.enumerated().map { index, participantID in
            let receivesRemainderUnit = Int64(index) < remainderUnits
            let units = baseUnits + (receivesRemainderUnit ? 1 : 0)

            return LedgerAllocation(
                participantID: participantID,
                amount: MoneyMath.decimal(fromMinorUnits: units, scale: currencyScale)
            )
        }
    }

    static func validatedExactAllocations(
        amount: Decimal,
        allocations: [LedgerAllocation],
        currencyScale: Int
    ) throws -> [LedgerAllocation] {
        try MoneyMath.validateScale(currencyScale)

        guard !allocations.isEmpty else {
            throw SettlementEngineError.emptyParticipantSet
        }

        let totalUnits = MoneyMath.minorUnits(amount, scale: currencyScale)
        guard totalUnits > 0 else {
            throw SettlementEngineError.invalidAmount
        }

        var seenParticipantIDs = Set<UUID>()
        var normalizedAllocations: [LedgerAllocation] = []
        var allocatedUnits: Int64 = 0

        for allocation in allocations {
            guard seenParticipantIDs.insert(allocation.participantID).inserted else {
                throw SettlementEngineError.duplicateAllocation(allocation.participantID)
            }

            let units = MoneyMath.minorUnits(allocation.amount, scale: currencyScale)
            guard units >= 0 else {
                throw SettlementEngineError.invalidAmount
            }

            allocatedUnits += units
            normalizedAllocations.append(
                LedgerAllocation(
                    participantID: allocation.participantID,
                    amount: MoneyMath.decimal(fromMinorUnits: units, scale: currencyScale)
                )
            )
        }

        guard allocatedUnits == totalUnits else {
            throw SettlementEngineError.allocationTotalMismatch(
                expectedMinorUnits: totalUnits,
                actualMinorUnits: allocatedUnits
            )
        }

        return normalizedAllocations
    }

    private static func validateUniqueParticipantIDs(_ participantIDs: [UUID]) throws {
        var seen = Set<UUID>()

        for participantID in participantIDs {
            guard seen.insert(participantID).inserted else {
                throw SettlementEngineError.duplicateParticipant(participantID)
            }
        }
    }
}
