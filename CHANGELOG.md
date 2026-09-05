# Changelog

All notable changes to Carry Splits will be documented here.

## [Unreleased]

### Added
- Initial repository foundation
- v1.0 product definition
- Architecture and roadmap documentation
- Release and security policies
- SwiftUI source skeleton
- SwiftData models for splits, participants, expenses, allocations, and completed settlement payments
- Currency-aware `Decimal` and minor-unit money utilities
- Equal and exact expense allocation engine
- Running balance and carry-forward ledger calculations
- Deterministic settlement plan generation
- SwiftData-to-ledger adapter layer
- Unit tests covering core allocation, balance, settlement, and validation behavior
- Create Split and Add Person flows
- Split Detail screen with live running balances and expense history
- Add/Edit Expense flow with equal and exact split controls
- Settle Up screen with immediate recalculation after completed payments
- Workflow tests covering create, expense, edit, balance, and settlement behavior
- SwiftData-backed CRUD for splits, participants, expenses, and settlement payments
- Split rename, archive, restore, and delete controls
- Active and archived split sections
- Participant rename and guarded deletion workflow
- Expense deletion with immediate ledger recalculation
- Fresh-`ModelContext` persistence tests covering reload, archive state, edits, safeguards, and deletion
- Native `ShareLink` settlement sharing
- `SettlementSummaryService` and deterministic share-summary tests
- Success sensory feedback when completed settlement payments are recorded
- Stable accessibility identifiers for high-value Phase 6 UI automation targets
- Brand, app-icon, and launch-presentation direction in `docs/BRAND.md`

### Changed
- App scene configures the SwiftData model container
- `SplitsViewModel` treats SwiftData as the source of truth and reloads UI snapshots after successful saves
- Archived splits are read-only until restored
- Existing Phase 3 workflow tests execute against an in-memory SwiftData container
- Split, balance, expense, and settlement rows now adapt more gracefully to larger Dynamic Type sizes
- VoiceOver labels and hints now describe balance meaning and non-obvious actions more explicitly
- Expense entry disables obviously incomplete saves and provides live exact-allocation reconciliation feedback
- Create, rename, and participant-entry forms improve keyboard focus and submit behavior
- Currency formatting now establishes locale before applying the requested currency code
- UI test planning now references stable accessibility identifiers
- Roadmap advanced through Phase 5 and now targets Phase 6 — Verification

### Fixed
- Stale expense-edit requests no longer create unsaved allocation objects before expense existence is validated
