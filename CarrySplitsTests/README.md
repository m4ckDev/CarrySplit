# CarrySplitsTests

Unit and workflow tests live here.

## Domain Coverage

`SettlementServiceTests.swift` covers:

- equal split remainder handling
- zero-decimal currency allocation
- exact allocation validation
- carry-forward balances across multiple payers
- completed settlement accounting
- settlement transfer generation
- exact debtor/creditor matching
- unbalanced ledger rejection
- unknown participant rejection

## Workflow Coverage

`SplitsViewModelTests.swift` runs the Phase 3 user workflow against an in-memory SwiftData container and covers:

- split creation
- participant creation
- expense creation
- expense editing
- balance recalculation
- settlement generation
- completed settlement recording
- case-insensitive duplicate participant rejection

## Persistence Coverage

`PersistenceTests.swift` creates fresh `ModelContext` instances against the same test container and covers:

- reconstructing a complete ledger from SwiftData
- persisted completed settlements
- split rename persistence
- archive-state persistence
- participant rename persistence
- protected deletion of participants referenced by history
- expense deletion persistence
- split deletion persistence

## Execution

The test source is authored in the repository. The full XCTest target will be executed during the Xcode verification phase after the project is assembled, including simulator and physical-device persistence checks.
