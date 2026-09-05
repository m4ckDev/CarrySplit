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

## Phase 6A — Automated Xcode Verification ✅

- Add canonical XcodeGen project definition
- Define app, unit-test, and UI-test targets
- Add iPhone app-icon asset catalog and deterministic icon generator
- Add neutral launch configuration
- Add macOS Xcode compile gate
- Generate the Xcode project successfully on macOS
- Compile the app and both test bundles successfully
- Run `build-for-testing` successfully
- Run the complete unit/workflow/persistence test suite through `xcodebuild test`
- Add and execute UI automation on an iPhone Simulator
- Verify split creation survives app termination and relaunch through SwiftData
- Add CI result artifacts and Xcode bootstrap documentation
- Enforce iPhone-only target configuration

## Phase 6B — Manual Device and Accessibility Verification

- Select the Apple Developer signing team in Xcode
- Test a physical iPhone
- Verify complete offline operation on-device
- Terminate/relaunch and verify SwiftData persistence on-device
- Visually inspect Light Mode and Dark Mode
- Test standard and accessibility Dynamic Type sizes
- Perform a VoiceOver navigation pass
- Test long names, large monetary amounts, and JPY values
- Inspect the app icon at actual Home Screen size
- Inspect the neutral launch-to-content transition
- Resolve any release-blocking local Xcode warnings

## Phase 7 — Release

- App Store screenshots
- App Store description and keywords
- Privacy details
- Pricing set to $1.99
- Archive in Xcode
- TestFlight validation
- App Review submission

## Current Milestone

**Phase 6B — Manual Device and Accessibility Verification**

Automated Xcode verification is green: the app and all test targets compile, the automated test suite runs successfully on a real iPhone Simulator, and UI automation verifies local SwiftData persistence across relaunch. The remaining Phase 6 work requires interactive Xcode and a physical iPhone before release preparation begins.
