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

## Phase 3 — Core UI ✅

- Build Splits screen
- Build Create Split flow
- Build participant entry flow
- Build Split Detail screen
- Build Add/Edit Expense flow
- Build equal/exact split controls
- Show live running balances
- Build Settle Up screen
- Recalculate settlement plan after marking payments paid
- Add empty states and validation feedback
- Add Phase 3 workflow tests

## Phase 4 — Persistence and Editing ✅

- Replace Phase 3 in-memory mutations with SwiftData-backed CRUD
- Persist newly created splits and participants
- Persist added and edited expenses
- Persist completed settlement payments
- Reload UI snapshots from SwiftData after every successful mutation
- Support split rename, archive, restore, and delete
- Show active and archived split sections
- Make archived splits read-only until restored
- Support participant renaming
- Prevent deletion of participants referenced by expense or settlement history
- Support expense deletion with immediate balance recalculation
- Add fresh-ModelContext persistence tests
- Verify saved ledger reconstruction through a new model context

## Phase 5 — Polish

- Native Share Sheet settlement summary
- Dynamic Type review
- VoiceOver review and labels
- Dark Mode verification
- Currency formatting review
- Haptics where useful
- App icon and launch presentation
- Final visual spacing and empty-state pass

## Phase 6 — Verification

- Unit test pass in Xcode
- UI test pass in Xcode
- Simulator testing
- Physical iPhone testing
- Offline testing
- Data persistence testing across app relaunch
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

**Phase 5 — Polish**

Carry Splits now uses SwiftData as its local source of truth. Splits, participants, expenses, allocations, archive state, edits, deletions, and completed settlement payments are saved locally and reconstructed into lightweight UI snapshots when loaded. The next milestone is visual, accessibility, sharing, and App Store-facing polish before the Xcode verification phase.
