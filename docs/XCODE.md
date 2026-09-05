# Carry Splits — Xcode Bootstrap and Verification

Carry Splits keeps `project.yml` as the canonical project definition. The generated `CarrySplits.xcodeproj` can be recreated at any time with XcodeGen.

## Requirements

- macOS
- Xcode with an iOS 17 or newer SDK
- Xcode command-line tools
- Homebrew
- XcodeGen

Install XcodeGen if needed:

```bash
brew install xcodegen
```

## Generate the App Icon Assets

From the repository root:

```bash
ICON_DIR="CarrySplits/Resources/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$ICON_DIR"
swift scripts/generate_app_icon.swift "$ICON_DIR/AppIcon-1024.png"
sips -z 40 40 "$ICON_DIR/AppIcon-1024.png" --out "$ICON_DIR/AppIcon-20@2x.png"
sips -z 60 60 "$ICON_DIR/AppIcon-1024.png" --out "$ICON_DIR/AppIcon-20@3x.png"
sips -z 58 58 "$ICON_DIR/AppIcon-1024.png" --out "$ICON_DIR/AppIcon-29@2x.png"
sips -z 87 87 "$ICON_DIR/AppIcon-1024.png" --out "$ICON_DIR/AppIcon-29@3x.png"
sips -z 80 80 "$ICON_DIR/AppIcon-1024.png" --out "$ICON_DIR/AppIcon-40@2x.png"
sips -z 120 120 "$ICON_DIR/AppIcon-1024.png" --out "$ICON_DIR/AppIcon-40@3x.png"
sips -z 120 120 "$ICON_DIR/AppIcon-1024.png" --out "$ICON_DIR/AppIcon-60@2x.png"
sips -z 180 180 "$ICON_DIR/AppIcon-1024.png" --out "$ICON_DIR/AppIcon-60@3x.png"
```

## Generate the Xcode Project

```bash
xcodegen generate
```

This creates:

```text
CarrySplits.xcodeproj
```

The project contains three targets:

- `CarrySplits`
- `CarrySplitsTests`
- `CarrySplitsUITests`

The shared `CarrySplits` scheme builds the app and runs both test targets.

## Open in Xcode

```bash
open CarrySplits.xcodeproj
```

## Command-Line Test

List available simulators:

```bash
xcrun simctl list devices available
```

Then run:

```bash
xcodebuild \
  -project CarrySplits.xcodeproj \
  -scheme CarrySplits \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=<YOUR IPHONE SIMULATOR>' \
  test
```

## Signing

The project intentionally does not hard-code an Apple Developer Team ID.

For physical-device testing or App Store archives:

1. Open the `CarrySplits` target in Xcode.
2. Open **Signing & Capabilities**.
3. Select your Apple Developer team.
4. Confirm the bundle identifier is available.

Current bundle identifier:

```text
com.m4ckdev.CarrySplits
```

If App Store Connect requires a different bundle identifier, update it in `project.yml` and regenerate the project rather than editing only the generated `.xcodeproj`.

## Verification Order

1. Clean Build Folder.
2. Build the `CarrySplits` target.
3. Run all `CarrySplitsTests` tests.
4. Run all `CarrySplitsUITests` tests.
5. Launch on a current simulator.
6. Test Light and Dark Mode.
7. Test large Dynamic Type.
8. Test VoiceOver navigation.
9. Create data, terminate the app, relaunch, and confirm persistence.
10. Disable networking and repeat the core workflow.
11. Run on a physical iPhone.
12. Resolve all compiler warnings before archive.

## Source-of-Truth Rule

Make structural project changes in `project.yml`, then run `xcodegen generate`.

Do not manually maintain two conflicting project definitions.
