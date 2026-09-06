# Carry Splits — Verification Status

## Phase 6A — Automated Xcode Verification ✅

Carry Splits has been compiled and tested on a hosted macOS runner using a real Xcode/iOS Simulator toolchain.

### Verified

- Xcode project generation from `project.yml`
- app-icon source generation and asset resizing
- `CarrySplits` application target compilation
- `CarrySplitsTests` unit/workflow/persistence test-bundle compilation
- `CarrySplitsUITests` UI-test-bundle compilation
- simulator-free `build-for-testing` compile gate
- real `xcodebuild test` execution on an available iPhone Simulator
- domain allocation and settlement tests
- workflow tests
- SwiftData persistence tests
- UI-test launch/create/relaunch persistence flow
- neutral launch-screen configuration
- iPhone-only target configuration

### Automated Results

The simulator-free compile gate completed successfully with Xcode 26.3 and Swift 6.2.3 and ended with:

```text
** TEST BUILD SUCCEEDED **
```

The corrected full iOS verification workflow also completed successfully with a real `xcodebuild test` run against an iPhone Simulator.

The canonical project definition is committed as `project.yml`. The generated `CarrySplits.xcodeproj` is a build artifact and can be recreated with:

```bash
xcodegen generate
```

See `docs/XCODE.md` for the complete bootstrap procedure.

## Phase 6B — Manual Device and Accessibility Verification ⏳

### Manual Simulator Verification ✅

The following checks were completed interactively on the iPhone 17 Pro simulator:

- app installs and launches from Xcode
- Apple Developer signing team configured locally
- create split workflow
- add and manage participants
- equal expense splitting
- exact-amount splitting
- invalid exact allocations are blocked from saving
- carry-forward balances across multiple expenses and different payers
- settlement calculation
- settlement payment completion
- native Share Sheet presentation
- copied settlement summary contains the correct names and amount with no internal IDs
- SwiftData persistence after app termination and relaunch
- complete workflow with simulator networking disabled
- Dark Mode
- accessibility Dynamic Type sizes
- Accessibility Inspector audit with no meaningful contrast, hit-region, description, or trait failures
- observed Accessibility Inspector Dynamic Type warnings despite correct semantic SwiftUI fonts and successful manual Dynamic Type behavior
- JPY zero-decimal currency handling
- integer remainder distribution for equal JPY splits
- long participant names
- long expense titles
- large monetary values
- generated Carry Splits app icon at Home Screen size

### Remaining Physical-Device Checks ⏳

The following checks require a physical iPhone before Phase 6 is fully closed:

- install and launch Carry Splits from Xcode on a physical iPhone
- verify the complete core workflow on-device
- disable networking and verify complete offline operation on-device
- terminate and relaunch on-device and confirm SwiftData persistence
- visually inspect Light Mode and Dark Mode on-device
- test standard and accessibility Dynamic Type sizes on-device
- perform a complete VoiceOver navigation pass
- inspect long participant and expense names on-device
- inspect large monetary values and JPY values on-device
- inspect the generated app icon at actual physical Home Screen size
- inspect the neutral launch-to-content transition on-device
- confirm no release-blocking compiler/signing warnings during the physical-device build

## Release Gate

Phase 7 should begin only after the remaining physical-device checks are complete or any discovered issues are fixed and retested.
