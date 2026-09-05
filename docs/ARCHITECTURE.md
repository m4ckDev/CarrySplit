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

### Views
SwiftUI presentation only. Views should not contain settlement mathematics or persistence rules.

### ViewModels
Screen state and user actions. ViewModels coordinate models and services but should not duplicate domain logic.

### Services
Pure domain operations such as allocation validation, balance calculation, and settlement planning. A small adapter layer converts SwiftData models into pure ledger values before math is performed.

### Utilities
Small reusable helpers such as currency formatting and decimal/minor-unit handling.

## Data Flow

User action -> View -> ViewModel -> SwiftData / Service -> Updated model -> View

For calculations:

SwiftData models -> `SplitLedgerAdapter` -> pure ledger values -> domain service -> balance / settlement result

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

The app scene owns one SwiftData model container shared by the view hierarchy.

## Testing Priority

Phase 2 domain tests cover:

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

Additional persistence and UI tests will be added when those layers are implemented.

## Dependency Rule

Third-party packages require a documented reason. Native Apple APIs are preferred whenever they meet the requirement.
