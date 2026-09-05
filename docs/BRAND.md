# Carry Splits — Brand and Visual Direction

## Product Character

Carry Splits should feel like a native iPhone utility, not a financial platform.

The interface is intentionally:

- quiet
- fast
- readable
- familiar
- uncluttered
- useful without onboarding

The product voice is plain and direct. Avoid financial jargon, marketing copy inside the app, and decorative UI that competes with balances or expenses.

## Core Line

**Split it. Carry it. Settle it.**

This line is appropriate for App Store marketing and product documentation. It does not need to be repeated throughout the application UI.

## Interface Styling

Carry Splits uses Apple semantic system styling wherever possible.

- system backgrounds
- primary and secondary semantic text
- standard SwiftUI lists and forms
- standard bordered/prominent actions
- system tint rather than hard-coded status colors
- SF Symbols for interface controls only

Balances communicate state with words and symbols, not color alone:

- Gets back
- Owes
- Even

This keeps the interface Dark Mode safe and accessible without creating a custom theme layer that the app does not need.

## App Icon Direction

The icon should communicate the product concept without relying on a currency symbol, country, or text.

### Concept

Use a simple abstract mark representing **split → carry forward → settle**:

1. Two separated ledger/path elements begin independently.
2. They visually move toward a single balanced endpoint.
3. The final mark feels stable and resolved rather than directional or aggressive.

The mark should remain recognizable at small Home Screen sizes.

### Avoid

- dollar, yen, euro, or other currency symbols
- calculator imagery
- receipt photography
- people silhouettes
- text or initials
- tiny numbers
- detailed gradients that disappear at small sizes
- manually drawn rounded app-icon corners

### Asset Target

Prepare the source artwork at **1024 × 1024 pixels** for the iOS asset catalog. Xcode can derive smaller icon sizes from the high-resolution source.

Current Apple platforms can also support dark and tinted icon appearances. Those variations should be derived from the same simple core mark rather than redesigned as unrelated icons.

Final binary icon artwork is exported and attached during Xcode asset-catalog assembly, when it can be inspected at actual Home Screen sizes before release.

## Launch Presentation

Carry Splits should not use a branded splash screen.

Launch presentation:

- system background
- no logo
- no tagline
- no loading spinner unless startup work genuinely requires one
- transition directly into the Splits screen

The purpose of the launch presentation is to make startup feel immediate, not to advertise the app to someone who already opened it.

## Typography

Use system typography and Dynamic Type.

- navigation titles: system navigation styles
- primary values: system body/title styles with monospaced digits where useful
- secondary information: system caption/footnote styles
- avoid hard-coded point sizes
- allow important rows to reflow vertically at larger accessibility sizes

## Accessibility Rules

- VoiceOver labels describe balance meaning, not just visible symbols.
- Action hints explain the result of uncommon actions.
- Important actions receive stable accessibility identifiers for UI testing.
- Status is never communicated using color alone.
- Layouts use `ViewThatFits` or natural wrapping where horizontal compression would harm readability.
- Standard SwiftUI controls are preferred for appropriate touch target behavior.

## Haptics

Use haptics sparingly.

A success feedback is appropriate when a real-world settlement payment is recorded because it changes the financial state of the ledger.

Routine navigation, typing, and every toggle should not produce extra feedback.

## Visual Review Checklist

Before release, verify in Xcode on at least one compact and one large iPhone size:

- Light Mode
- Dark Mode
- standard Dynamic Type
- largest accessibility Dynamic Type sizes
- VoiceOver navigation order
- long participant names
- long expense names
- large monetary amounts
- zero-decimal currency values
- App Icon at Home Screen size
- launch-to-content transition
