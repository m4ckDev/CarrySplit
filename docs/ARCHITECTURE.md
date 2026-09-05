# Carry Splits — Architecture

## Objective

Keep Carry Splits small, testable, local-first, and easy to maintain.

## Stack

- Swift
- SwiftUI
- SwiftData
- Lightweight MVVM
- Apple frameworks only for v1.0 unless a dependency is clearly justified

## Layer Boundaries

### Models
Persisted application data such as splits, participants, expenses, allocations, and completed settlement payments.

Lightweight UI snapshot structs mirror persisted records for presentation. They are rebuilt from SwiftData after successful mutations and are never an independent source of truth.

### Views
SwiftUI presentation only. Views should not contain settlement mathematics or persistence rules.

### ViewModels
Screen state and user actions. `SplitsViewModel` owns the `ModelContext` boundary for v1.0 CRUD operations. It validates user intent, updates SwiftData, explicitly saves, then reloads presentation snapshots.

### Services
Pure domain operations such as allocation validation, balance calculation, and settlement planning. A small adapter layer converts persisted or snapshot data into pure ledger values before math is performed.

### Utilities
Small reusable helpers such as currency formatting and decimal/minor-unit handling.

## Data Flow

For a mutation:

User action -> View -> ViewModel -> SwiftData mutation -> `ModelContext.save()` -> reload snapshots -> View

For calculations:

Persisted data / UI snapshot -> pure ledger values -> domain service -> balance / settlement result

SwiftData remains the source of truth. UI snapshots exist only to keep SwiftUI presentation simple and calculation services persistence-agnostic.

## Persisted Domain

### ExpenseSplit

Owns the local split and its currency rules.

Key fields:

- Name
- ISO currency code
- Persisted currency fraction digits
- Archived state
- Participants
- Expenses
- Completed settlement payments

Persisting the currency fraction digits prevents a future formatter or OS behavior change from altering the math of an existing split.

### Participant

Stores a local display name and deterministic sort order. No account, email address, phone number, or remote identity is required.

Historical ledger records reference participants by UUID rather than by display name. This allows a participant to be renamed without rewriting expense or settlement history.

### Expense

Stores the amount, payer identifier, split method, date, and concrete allocations.

Equal splits are converted into concrete allocations when the expense is created. This means historical ledger math does not need to re-run an equal-split formula every time balances are displayed.

### ExpenseAllocation

Stores the exact amount attributed to one participant for one expense.

The sum of allocations must equal the expense total at the split's currency precision.

### SettlementPayment

Represents a transfer the user has actually marked as completed.

Generated settlement recommendations are not persisted. Once a suggested transfer is marked paid, it becomes a `SettlementPayment` and therefore part of the ledger. The next settlement plan is recalculated from the updated balances.

## Money Rules

1. Persist and display monetary values as `Decimal`.
2. Convert values to integer minor units before allocation and settlement math.
3. Use the split's persisted currency fraction-digit value for all calculations.
4. Equal-split remainder units are assigned deterministically in participant-selection order.
5. Exact allocations must reconcile to the expense total in minor units.
6. Running balances must always sum to zero.
7. A completed settlement moves the sender's negative balance and receiver's positive balance toward zero.

Examples:

- USD $10.00 split three ways -> $3.34, $3.33, $3.33
- JPY ¥1,000 split three ways -> ¥334, ¥333, ¥333

## Settlement Planning

The settlement planner first nets all historical expenses and completed settlement payments into one balance per participant.

Positive balance = participant should receive money.

Negative balance = participant owes money.

The planner then:

1. Removes exact debtor/creditor matches first.
2. Matches remaining largest balances deterministically.
3. Ensures every transfer completely resolves at least one side of the transaction.
4. Produces no circular or zero-value transfers.

This is intentionally a practical deterministic optimizer for a small consumer group-expense app, rather than an expensive global combinatorial optimizer.

## Editing and Deletion Rules

1. Split names can be changed without affecting the ledger.
2. Participant names can be changed because historical records use UUIDs.
3. A participant cannot be deleted while referenced as an expense payer, allocation participant, or completed settlement endpoint.
4. Deleting an expense removes that expense and its allocation children, then recalculates balances from the remaining ledger.
5. Deleting a split removes its participants, expenses, allocations, and settlement records through SwiftData cascade relationships.
6. Archived splits remain visible but are read-only until restored.
7. Completed settlement payments remain historical ledger entries even if later expenses are edited or deleted.

## Domain Rules

1. Monetary calculations use `Decimal`, never floating-point `Double`.
2. Every expense has exactly one payer.
3. Every expense has at least one allocation.
4. Exact allocations must reconcile to the expense total.
5. Expense and settlement participant identifiers must belong to the split.
6. Running balances must sum to zero after currency rounding rules are applied.
7. Settlement logic must be deterministic and independent of SwiftUI.
8. Generated settlement suggestions are disposable calculations, not persisted truth.
9. Deleting or changing data must never silently corrupt historical expenses.

## Persistence

SwiftData stores all v1.0 customer data locally on the device.

No remote database, account service, analytics SDK, ad SDK, or cloud synchronization is required for v1.0.

The app scene owns one SwiftData model container shared by the view hierarchy. `SplitsView` supplies the environment `ModelContext` to `SplitsViewModel`, which explicitly saves every successful mutation.

A reload reconstructs all `SplitSession` presentation snapshots from fetched `ExpenseSplit` records. Persistence tests create a fresh `ModelContext` against the same test container to confirm data is reconstructed from storage rather than retained only in view-model memory.

## Testing Coverage

Domain and workflow tests cover:

- Equal splits with currency remainder
- Zero-decimal currency splitting
- Exact amount validation
- Multiple payers across multiple expenses
- Carry-forward running balances
- Partial completed settlements
- Settlement reduction
- Exact debtor/creditor matching
- Unbalanced ledger rejection
- Unknown participant rejection
- Full create -> expense -> settlement workflow against SwiftData
- Expense editing and balance recalculation
- Case-insensitive duplicate participant rejection
- Fresh-context ledger reload
- Split rename and archive persistence
- Participant rename persistence
- Historical participant deletion safeguards
- Expense deletion persistence
- Full split deletion persistence

The test files are present in the repository. Final compiler execution and simulator/device verification remain part of Phase 6 in Xcode.

## Dependency Rule

Third-party packages require a documented reason. Native Apple APIs are preferred whenever they meet the requirement.
