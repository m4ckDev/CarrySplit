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

## Phase 6B — Manual Device and Accessibility Verification ⏳

Completed in simulator/manual testing:

- Core create/add/split/settle workflow
- Terminate/relaunch SwiftData persistence
- Offline operation
- Light/Dark presentation
- Accessibility Dynamic Type
- Accessibility Inspector audit
- Long names and large monetary values
- JPY / zero-decimal currency
- Uneven remainder handling
- Exact-split validation
- Native settlement sharing
- App icon at Home Screen size

Still required before final App Review submission:

- Run the release candidate on a physical iPhone
- Perform the VoiceOver common-workflow pass on a physical iPhone
- Verify the TestFlight build on a physical iPhone
- Resolve any physical-device release blocker discovered by those checks

## Phase 7 — Release Preparation 🚧

### Phase 7A — Metadata and Compliance

- [x] Prepare App Store name, subtitle, description, promotional text, and keywords
- [x] Prepare App Review notes
- [x] Prepare App Privacy answers
- [x] Add app privacy manifest
- [x] Add export-compliance declaration
- [x] Prepare privacy-policy copy
- [x] Prepare support-page copy
- [x] Prepare screenshot plan
- [x] Prepare Xcode/TestFlight/App Review runbook
- [ ] Publish Privacy Policy URL
- [ ] Publish Support URL with real contact information
- [ ] Create App Store Connect app record
- [ ] Confirm Carry Splits name availability
- [ ] Complete age-rating questionnaire
- [ ] Complete app accessibility declarations for verified features

### Phase 7B — Commercial Setup

- [ ] Accept Paid Apps Agreement
- [ ] Complete required tax/banking setup
- [ ] Set base pricing and $1.99 U.S. price
- [ ] Confirm storefront availability

### Phase 7C — Store Assets

- [ ] Capture final 6.9-inch iPhone screenshots
- [ ] Compose/upload final product-page screenshots
- [ ] Verify listing metadata in App Store Connect

### Phase 7D — Build and TestFlight

- [ ] Regenerate final Xcode project
- [ ] Archive release build
- [ ] Validate archive
- [ ] Upload build 1.0.0 (1)
- [ ] Wait for App Store Connect processing
- [ ] Install via TestFlight on physical iPhone
- [ ] Finish Phase 6B physical-device and VoiceOver gate

### Phase 7E — App Review

- [ ] Select processed build for version 1.0.0
- [ ] Complete review contact fields
- [ ] Verify privacy/support URLs
- [ ] Verify pricing and availability
- [ ] Verify screenshots and metadata
- [ ] Select Manual Release
- [ ] Submit for App Review

## Current Milestone

**Phase 7A — App Store Release Preparation**

Release preparation has started. Metadata, compliance documentation, privacy/support copy, screenshot direction, and the submission runbook are now in the repository. Final App Review submission remains gated by live support/privacy URLs, App Store Connect commercial setup, screenshots, archive/TestFlight processing, and the remaining physical-iPhone/VoiceOver verification.
