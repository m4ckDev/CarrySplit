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
- In-memory Phase 3 split, participant, expense, and settlement UI state
- Create Split and Add Person flows
- Split Detail screen with live running balances and expense history
- Add/Edit Expense flow with equal and exact split controls
- Settle Up screen with immediate recalculation after completed payments
- Workflow tests covering create, expense, edit, balance, and settlement behavior

### Changed
- App scene configures the SwiftData model container
- Roadmap advanced through Phase 3 and now targets Phase 4 — Persistence and Editing
