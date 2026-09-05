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
Persisted application data such as splits, participants, expenses, allocations, and settlement records.

### Views
SwiftUI presentation only. Views should not contain settlement mathematics or persistence rules.

### ViewModels
Screen state and user actions. ViewModels coordinate models and services but should not duplicate domain logic.

### Services
Pure domain operations such as balance calculation, validation, and settlement optimization.

### Utilities
Small reusable helpers such as currency formatting and decimal handling.

## Data Flow

User action -> View -> ViewModel -> Service / SwiftData -> Updated model -> View

## Domain Rules

1. Monetary calculations use `Decimal`, not floating-point `Double`.
2. Every expense has exactly one payer.
3. Every expense has at least one participant.
4. Exact allocations must reconcile to the expense total.
5. Running balances must sum to zero after rounding rules are applied.
6. Settlement logic must be deterministic and independent of SwiftUI.
7. Deleting or changing data must never silently corrupt historical expenses.

## Persistence

SwiftData stores all v1.0 customer data locally on the device.

No remote database, account service, analytics SDK, ad SDK, or cloud synchronization is required for v1.0.

## Testing Priority

Highest-priority unit tests:

- Equal splits with exact divisibility
- Equal splits with currency remainder
- Exact amount validation
- Multiple payers across multiple expenses
- Positive and negative running balances
- Settlement reduction
- Already-settled groups
- Edited and deleted expenses
- Rounding invariants

## Dependency Rule

Third-party packages require a documented reason. Native Apple APIs are preferred whenever they meet the requirement.
