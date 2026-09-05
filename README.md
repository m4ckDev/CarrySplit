# Carry Splits

**Split it. Carry it. Settle it.**

Carry Splits is a small, local-first iPhone expense splitter. One person records shared expenses, balances carry forward automatically, and the app produces a simple final settlement without accounts, subscriptions, ads, or a required internet connection.

## Status

**Phase 3 — Core UI complete.**

The repository now contains the complete in-memory SwiftUI workflow: create a split, add participants, add or edit expenses, see live running balances, generate an optimized settlement plan, and mark settlement payments paid. Phase 4 will connect this workflow to the existing SwiftData domain so customer data persists across app launches.

## v1.0 Scope

- Create, rename, archive, and delete splits
- Add and manage participants by name
- Add, edit, and delete shared expenses
- Equal and exact-amount splitting
- Continuous running balances
- Optimized settlement calculation
- Mark settlement transfers as paid
- Share a settlement summary with the native iOS Share Sheet
- Persist all data locally on-device
- Work without an account or internet connection

## Product Rule

> Does this make splitting and settling expenses faster?

If the answer is no, it does not belong in Carry Splits v1.0.

## Technical Direction

| Area | Decision |
| --- | --- |
| Platform | iPhone / iOS |
| Language | Swift |
| UI | SwiftUI |
| Persistence | SwiftData |
| Architecture | Lightweight MVVM |
| Money math | `Decimal` + integer minor units |
| Backend | None for v1.0 |
| Authentication | None |
| Networking | None required |
| Business model | $1.99 one-time purchase |

The planned minimum deployment target is iOS 17.0 so the app can use SwiftData while retaining broad device compatibility.

## Repository Layout

```text
CarrySplit/
├── CarrySplits/
│   ├── App/
│   ├── Views/
│   ├── Models/
│   ├── ViewModels/
│   ├── Services/
│   ├── Utilities/
│   └── Resources/
├── CarrySplitsTests/
├── CarrySplitsUITests/
├── docs/
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── SECURITY.md
└── README.md
```

## Current User Flow

1. Create a split and choose its currency.
2. Add participants by name.
3. Add an expense and choose who paid.
4. Choose who participated in the expense.
5. Split equally or enter exact amounts.
6. See everyone's running balance update immediately.
7. Open Settle Up to generate the remaining transfers.
8. Mark a real-world payment paid and recalculate the plan.

Phase 3 uses temporary in-memory session models so the full experience can be developed independently from persistence. Phase 4 will replace that temporary state with SwiftData-backed CRUD without changing the settlement engine.

## Core Domain

Persisted entities already defined for Phase 4:

- `ExpenseSplit`
- `Participant`
- `Expense`
- `ExpenseAllocation`
- `SettlementPayment`

Pure calculation types and services are intentionally separate from SwiftData. The settlement engine receives plain ledger values, calculates balances in integer minor units, and converts results back to `Decimal` for persistence and display.

A completed settlement is recorded as a ledger payment. Generated settlement recommendations are not persisted until the user marks a payment as completed, preventing stale recommendations from becoming source-of-truth data.

## Development Principles

1. Keep the interaction model shallow and fast.
2. Prefer native Apple frameworks over third-party dependencies.
3. Keep settlement calculations independent from the UI and persistence layers.
4. Keep customer expense data on-device in v1.0.
5. Require tests for balance and settlement calculations.
6. Avoid infrastructure that does not directly improve the core split-and-settle workflow.

## Documentation

- `docs/PRODUCT.md` — locked v1.0 product definition
- `docs/ARCHITECTURE.md` — technical boundaries and data flow
- `docs/ROADMAP.md` — implementation sequence
- `docs/RELEASE_CHECKLIST.md` — App Store readiness checklist

## License

Copyright © 2026. All rights reserved. This is proprietary software; see `LICENSE`.
