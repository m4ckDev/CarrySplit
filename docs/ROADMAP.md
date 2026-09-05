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

## Phase 4 — Persistence and Editing

- Replace Phase 3 in-memory session state with SwiftData-backed CRUD
- Persist newly created splits and participants
- Persist added and edited expenses
- Persist completed settlement payments
- Support split rename, archive, and delete
- Support participant editing with historical-data safeguards
- Support expense deletion with recalculation
- Verify relaunch persistence
- Add persistence-focused tests

## Phase 5 — Polish

- Native Share Sheet settlement summary
- Dynamic Type
- VoiceOver labels
- Dark Mode verification
- Currency formatting review
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

**Phase 4 — Persistence and Editing**

The complete in-memory SwiftUI workflow is established: create a split, add participants, enter or edit expenses, see live balances, generate settlements, and mark payments paid. The next milestone replaces the temporary session state with the existing SwiftData domain so all customer data survives relaunch.
