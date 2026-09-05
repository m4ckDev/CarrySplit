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

## Phase 5 — Polish ✅

- Add native SwiftUI settlement sharing with `ShareLink`
- Add deterministic share-summary generation and tests
- Improve Dynamic Type behavior with adaptive `ViewThatFits` layouts
- Review VoiceOver labels, hints, and reading order
- Add stable accessibility identifiers for Phase 6 UI automation
- Keep status communication independent from color
- Review interface styling for semantic Light/Dark Mode behavior
- Review currency formatting and locale ordering
- Add restrained success sensory feedback when a settlement payment is recorded
- Improve form focus, validation, and exact-allocation feedback
- Improve empty states and participant-management presentation
- Lock app-icon direction and launch-presentation rules in `docs/BRAND.md`

## Phase 6 — Verification

- Assemble the Xcode project and targets
- Attach all source files to the correct application/test targets
- Export/import the final 1024 × 1024 app-icon artwork into the asset catalog
- Configure the neutral launch presentation
- Run a clean Xcode build with zero compiler errors
- Resolve compiler warnings
- Run the complete unit/workflow/persistence test suite
- Build and run UI automation against stable accessibility identifiers
- Test a current iPhone simulator
- Test the oldest supported iOS 17 simulator available
- Test a physical iPhone
- Verify complete offline operation
- Terminate/relaunch and verify SwiftData persistence
- Visually inspect Light Mode and Dark Mode
- Test standard and accessibility Dynamic Type sizes
- Perform a VoiceOver navigation pass
- Test long names, large monetary amounts, and JPY values

## Phase 7 — Release

- App Store screenshots
- App Store description and keywords
- Privacy details
- Pricing set to $1.99
- Archive in Xcode
- TestFlight validation
- App Review submission

## Current Milestone

**Phase 6 — Verification**

The v1.0 feature set, local persistence layer, sharing flow, accessibility hooks, adaptive layouts, and visual direction are now established in source. The next milestone is the first real Xcode compile/test cycle, simulator and device validation, final icon attachment, and release-quality verification.
