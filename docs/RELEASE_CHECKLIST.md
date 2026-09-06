# Carry Splits — Release Checklist

## Product
- [x] v1.0 scope complete
- [x] No out-of-scope features introduced
- [x] Core workflow can be completed quickly without onboarding

## Functional
- [x] Create split
- [x] Add participants
- [x] Add equal-split expense
- [x] Add exact-amount expense
- [x] Invalid exact allocations are rejected
- [x] Edit and delete expense logic covered by automated tests
- [x] Running balances remain correct
- [x] Settlement plan remains correct
- [x] Mark settlement complete
- [x] Share settlement summary
- [x] Archive and delete split logic covered by automated tests

## Data
- [x] Data survives app restart in simulator/manual verification
- [x] Offline operation verified in simulator
- [x] No intended network dependency in v1.0
- [x] Corrupt or invalid allocations are rejected
- [x] JPY / zero-decimal currency verified
- [x] Uneven remainder allocation verified
- [x] Large monetary values verified

## Quality
- [x] Unit tests pass in hosted Xcode verification
- [x] UI tests pass in hosted Xcode verification
- [x] Simulator-free build-for-testing passes
- [x] No known app crash in verified workflows
- [x] Dynamic Type verified manually
- [x] Dark Mode verified manually
- [x] Accessibility Inspector audit completed; no release-blocking contrast/hit-region/description issue found
- [ ] VoiceOver common workflow verified on physical iPhone
- [ ] Physical-device release build verified

## Device Testing
- [x] Current iPhone simulator
- [ ] Oldest supported iOS 17.x device/simulator check
- [ ] Physical iPhone

## App Store Metadata
- [x] App name intended: Carry Splits
- [x] Bundle identifier finalized: `com.m4ckdev.CarrySplits`
- [x] Version set: `1.0.0`
- [x] Initial build number set: `1`
- [x] App icon generated and visually verified
- [x] Description prepared
- [x] Subtitle prepared
- [x] Promotional text prepared
- [x] Keywords prepared
- [x] App Review notes prepared
- [x] Screenshot plan prepared
- [x] Privacy policy copy prepared
- [x] Support page copy prepared
- [x] App Privacy answers prepared: Data Not Collected
- [x] Privacy manifest added to app target definition
- [x] Export-compliance Info.plist declaration prepared
- [ ] Exact App Store name availability confirmed in App Store Connect
- [ ] Screenshots captured and uploaded
- [ ] Public Support URL live with real contact information
- [ ] Public Privacy Policy URL live
- [ ] App Privacy answers entered in App Store Connect
- [ ] Age-rating questionnaire completed
- [ ] App accessibility labels entered only for verified features
- [ ] Copyright/legal developer name entered

## Commercial / Account
- [ ] Paid Apps Agreement accepted
- [ ] Required tax information complete
- [ ] Required banking information complete
- [ ] Base country/region selected
- [ ] U.S. storefront price set to $1.99
- [ ] Availability regions confirmed

## Distribution
- [ ] App Store Connect app record created
- [ ] Release archive succeeds locally
- [ ] Archive validation passes
- [ ] Build uploaded to App Store Connect
- [ ] Build processing completes
- [ ] TestFlight internal install verified on physical iPhone
- [ ] TestFlight VoiceOver pass completed
- [ ] Version 1.0.0 build selected for App Review
- [ ] App Review contact information complete
- [ ] All required metadata fields green in App Store Connect
- [ ] Manual release selected unless launch strategy changes
- [ ] App Review submission sent

## Source of Truth

- `docs/APP_STORE_METADATA.md` — listing copy and App Store field values
- `docs/APP_STORE_SCREENSHOTS.md` — screenshot capture plan
- `docs/PRIVACY_POLICY.md` — privacy-policy copy to publish publicly
- `docs/SUPPORT.md` — support-page copy to publish publicly
- `docs/RELEASE_RUNBOOK.md` — Xcode, TestFlight, and submission procedure
- `docs/VERIFICATION.md` — test and verification record
