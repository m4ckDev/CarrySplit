# CarrySplitsTests

Domain unit tests live here.

## Phase 2 Coverage

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

## Execution

The tests are authored now and will be attached to the Carry Splits XCTest target when the Xcode project is generated. Full test execution is part of the later verification phase, consistent with the project's code-first workflow.
