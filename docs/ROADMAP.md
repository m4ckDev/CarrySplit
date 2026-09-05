# Carry Splits — Roadmap

## Phase 1 — Foundation ✅

- Lock v1.0 product scope
- Establish repository structure
- Add documentation and policies
- Add Swift source skeleton

## Phase 2 — Core Domain ✅

- Define SwiftData models
- Implement split, participant, expense, allocation, and settlement relationships
- Implement currency-aware minor-unit math
- Implement equal split calculations
- Implement exact amount allocations and validation
- Implement running balance calculations
- Implement completed settlement accounting
- Implement deterministic settlement optimization
- Add unit tests for core domain math

## Phase 3 — Core UI

- Build Splits screen
- Build Create Split flow
- Build Split Detail screen
- Build Add/Edit Expense flow
- Build Settle Up screen
- Add empty states and validation feedback

## Phase 4 — Persistence and Editing

- Wire SwiftUI CRUD operations to SwiftData
- Support rename, archive, and delete
- Support participant editing with historical-data safeguards
- Support expense editing and deletion
- Persist completed settlement payments
- Verify relaunch persistence

## Phase 5 — Polish

- Native Share Sheet settlement summary
- Dynamic Type
- VoiceOver labels
- Dark Mode verification
- Currency formatting
- Haptics where useful
- App icon and launch presentation

## Phase 6 — Verification

- Unit test pass
- UI test pass
- Simulator testing
- Physical iPhone testing
- Offline testing
- Data persistence testing
- Accessibility pass

## Phase 7 — Release

- App Store screenshots
- App Store description and keywords
- Privacy details
- Pricing set to $1.99
- Archive in Xcode
- TestFlight validation
- App Review submission

## Current Milestone

**Phase 3 — Core UI**

The domain ledger and settlement engine are established. The next milestone is the first complete user workflow: create a split, add participants, enter an expense, see balances, and settle up.
