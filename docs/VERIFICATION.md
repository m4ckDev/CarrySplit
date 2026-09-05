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

The following checks require interactive Xcode/device access and remain before Phase 6 is fully closed:

- run on a physical iPhone
- select the Apple Developer signing team
- verify install/launch from Xcode on-device
- verify complete core workflow with networking disabled
- terminate and relaunch on-device and confirm SwiftData persistence
- visually inspect Light Mode
- visually inspect Dark Mode
- test standard Dynamic Type
- test accessibility Dynamic Type sizes
- perform a VoiceOver navigation pass
- inspect long participant and expense names
- inspect large monetary values
- inspect JPY/zero-decimal values
- inspect the generated app icon at actual Home Screen size
- inspect the neutral launch-to-content transition
- confirm no release-blocking compiler warnings after local project regeneration

## Release Gate

Phase 7 should begin only after the Phase 6B manual checks are complete or any discovered issues are fixed and retested.
