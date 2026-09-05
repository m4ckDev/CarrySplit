# CarrySplitsUITests

UI tests live here and are executed by the Phase 6 macOS verification workflow.

## Implemented Coverage

`CarrySplitsUITests.swift` currently verifies:

- app launch reaches the Splits screen
- a new split can be created through the real SwiftUI flow
- the created split appears in the list
- terminating and relaunching the app preserves that split through SwiftData

## Next UI Verification Coverage

- add participants
- add an expense
- edit an expense
- open Settle Up
- share a settlement summary
- mark a settlement paid
- archive and restore a split
- verify key flows at large Dynamic Type sizes where practical

## Stable Accessibility Identifiers

The Phase 5 UI pass added stable identifiers for high-value controls, including:

- `splits.new`
- `splits.list`
- `createSplit.name`
- `createSplit.currency`
- `createSplit.create`
- `addPerson.name`
- `addPerson.add`
- `split.detail`
- `split.actions`
- `split.addExpense`
- `split.settleUp`
- `expense.title`
- `expense.amount`
- `expense.payer`
- `expense.splitMethod`
- `expense.save`
- `expense.delete`
- `settlement.share`
- `settlement.markPaid`

Dynamic row identifiers use the model UUID, for example `split.row.<UUID>`, `expense.row.<UUID>`, and `participant.row.<UUID>`.
