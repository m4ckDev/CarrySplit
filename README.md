# Carry Splits

**Split it. Carry it. Settle it.**

Carry Splits is a small, local-first iPhone expense splitter. One person records shared expenses, balances carry forward automatically, and the app produces a simple final settlement without accounts, subscriptions, ads, or a required internet connection.

## Status

**Phase 5 — Polish complete.**

Carry Splits now has the full v1.0 source workflow, SwiftData persistence, native settlement sharing, adaptive large-text layouts, VoiceOver-oriented labels and hints, stable accessibility identifiers, locale-safe currency formatting, and restrained settlement haptics. Phase 6 is the first full Xcode compile, simulator/device, accessibility, persistence, and UI-test verification cycle.

## v1.0 Scope

- Create, rename, archive, restore, and delete splits
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
| Sharing | Native SwiftUI `ShareLink` |
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
5. Split equally or enter exact amounts with live reconciliation feedback.
6. See everyone's running balance update immediately.
7. Open Settle Up to generate the remaining transfers.
8. Share the settlement plan through the native iOS Share Sheet when needed.
9. Mark a real-world payment paid and recalculate the plan.
10. Rename, archive, restore, or delete the split as needed.
11. Close and reopen the app with the local ledger preserved by SwiftData.

## Persistence Design

SwiftData is the source of truth for customer data.

Persisted entities:

- `ExpenseSplit`
- `Participant`
- `Expense`
- `ExpenseAllocation`
- `SettlementPayment`

The UI does not independently own mutable ledger data. `SplitsViewModel` writes each successful mutation to `ModelContext`, saves it, then rebuilds lightweight `SplitSession` snapshots from SwiftData for presentation.

This keeps the settlement engine independent from persistence while preventing session state and stored state from drifting apart.

Historical safeguards prevent deleting a participant while that person is referenced by an expense or completed settlement. Renaming a participant is safe because historical records reference stable UUIDs rather than names.

Generated settlement recommendations are not stored as source-of-truth records. A settlement becomes persisted history only after the user marks that payment as completed.

## Polish and Accessibility

Carry Splits intentionally stays close to native iOS conventions rather than introducing a custom visual framework.

- semantic system colors for Light/Dark Mode compatibility
- Dynamic Type-friendly layouts using natural wrapping and `ViewThatFits`
- VoiceOver labels and hints for balance meaning and non-obvious actions
- stable accessibility identifiers for UI automation
- status communicated with words and symbols rather than color alone
- success sensory feedback only when a settlement payment is recorded
- native sharing through `ShareLink`
- no branded splash screen

The final app-icon artwork and launch target configuration will be attached and visually verified during Phase 6 Xcode assembly.

## Development Principles

1. Keep the interaction model shallow and fast.
2. Prefer native Apple frameworks over third-party dependencies.
3. Keep settlement calculations independent from the UI and persistence layers.
4. Keep customer expense data on-device in v1.0.
5. Require tests for balance, settlement, persistence, and share-summary behavior.
6. Avoid infrastructure that does not directly improve the core split-and-settle workflow.

## Documentation

- `docs/PRODUCT.md` — locked v1.0 product definition
- `docs/ARCHITECTURE.md` — technical boundaries and data flow
- `docs/ROADMAP.md` — implementation sequence
- `docs/BRAND.md` — visual, accessibility, icon, and launch direction
- `docs/RELEASE_CHECKLIST.md` — App Store readiness checklist

## License

Copyright © 2026. All rights reserved. This is proprietary software; see `LICENSE`.
