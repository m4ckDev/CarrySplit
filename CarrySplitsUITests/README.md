# CarrySplitsUITests

UI tests belong here and will be executed once the Xcode project is assembled.

## Phase 6 Priority

- launch into the Splits screen
- create a split
- add participants
- add an expense
- edit an expense
- open Settle Up
- share a settlement summary
- mark a settlement paid
- archive and restore a split
- verify persistence after relaunch
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
