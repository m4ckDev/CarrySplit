# Carry Splits — App Store Metadata

## App Record

- **Platform:** iOS
- **App Name:** Carry Splits
- **Primary Language:** English (U.S.)
- **Bundle ID:** `com.m4ckdev.CarrySplits`
- **SKU:** `CARRYSPLITS-IOS-001`
- **Version:** `1.0.0`
- **Build:** `1`
- **Primary Category:** Finance
- **Secondary Category:** Travel
- **Business Model:** Paid app, one-time purchase
- **Target U.S. Price:** $1.99
- **In-App Purchases:** None
- **Subscriptions:** None

> Confirm that the App Store name is available when creating the App Store Connect app record. The bundle ID must match the Xcode build exactly.

## Product Page

### Subtitle

**Shared expenses, settled fast**

### Promotional Text

Shared expenses without the setup. Add people, record expenses, carry balances forward, and settle once — all locally on your iPhone.

### Description

Split shared expenses without accounts, ads, subscriptions, or complicated setup.

Carry Splits is a fast, private expense splitter for trips, dinners, roommates, couples, family expenses, and temporary groups. Add people, record who paid, choose who participated, and let running balances carry forward until you're ready to settle.

FEATURES

• Equal and exact-amount splits
• Running balances across multiple expenses
• A simple settlement plan showing who pays whom
• Mark settlement payments complete
• Native iOS sharing
• Local on-device storage
• Works offline
• No accounts, ads, subscriptions, or bank connections

HOW IT WORKS

1. Create a split and choose a currency.
2. Add people by name.
3. Record expenses as they happen.
4. Carry balances forward.
5. Settle once when you're done.

PRIVACY

Your expenses stay on your iPhone. Carry Splits does not require an account, email address, phone number, contact upload, location access, bank connection, or advertising identifier.

Split it. Carry it. Settle it.

### Keywords

`expense,bill,group,travel,trip,roommates,dinner,share,settlement,owed,offline,friends,family`

The keyword string is under Apple's 100-byte limit and intentionally does not repeat the app name or developer name.

### What's New — Version 1.0.0

Carry Splits 1.0 introduces fast shared-expense tracking, equal and exact splits, running balances, simplified settlement plans, local persistence, offline use, and native sharing.

## URLs

These must be live public webpages before App Review submission.

- **Support URL:** TBD — publish the content in `docs/SUPPORT.md`
- **Privacy Policy URL:** TBD — publish the content in `docs/PRIVACY_POLICY.md`
- **Marketing URL:** Optional; not required for v1.0
- **Accessibility URL:** Optional; can be added later

## App Privacy

For v1.0, provided the shipped build remains identical to the current architecture and no analytics/advertising/third-party data SDK is added:

- **Does this app or third-party partners collect data?** No
- **Tracking:** No
- **Advertising:** No
- **Analytics SDK:** None
- **Account information:** None
- **Contact information:** None
- **Financial account information:** None
- **Location:** None
- **Device identifiers for advertising/tracking:** None

Expected App Store privacy label: **Data Not Collected**.

A valid `PrivacyInfo.xcprivacy` is included in the application target and declares no tracking, collected data types, or required-reason API categories used directly by Carry Splits.

## Age Rating

Expected result: **4+**, assuming the App Store Connect questionnaire is answered consistently with the current v1.0 feature set:

- No violence
- No sexual/suggestive content
- No profanity
- No horror/fear content
- No gambling or contests
- No advertising
- No user-generated content
- No messaging/chat
- No unrestricted web access

App Store Connect calculates the final global and region-specific rating from Apple's questionnaire.

## Accessibility Nutrition Labels

Only claim support after the relevant common tasks have been verified.

Current evidence supports:

- Larger Text — verified in simulator
- Dark Interface — verified in simulator
- Differentiate Without Color Alone — status is expressed with text, not only color
- Sufficient Contrast — Accessibility Inspector audit produced no contrast failure

Pending physical-device verification before claiming:

- VoiceOver
- Voice Control

Do not publish an accessibility label merely because the API is present; all common app tasks must work with that feature.

## Export Compliance

Carry Splits does not implement proprietary or non-exempt encryption. `ITSAppUsesNonExemptEncryption` is set to `false` in the release configuration/Info.plist to streamline App Store Connect processing.

## App Review Notes

Carry Splits is a paid, local-only shared-expense utility. No account, login, network connection, in-app purchase, subscription, advertising SDK, bank connection, or external payment service is required.

Suggested review path:

1. Launch Carry Splits.
2. Tap the plus button to create a split.
3. Add two or more participants by name.
4. Add an expense and choose the payer and participants.
5. Review the running balances.
6. Open Settle Up to see the settlement plan.
7. Optionally use Share to open the native iOS Share Sheet.
8. Mark a settlement payment complete.
9. Terminate and reopen the app to confirm local persistence.

Data is persisted locally using SwiftData. The app is designed to work fully offline.

## App Review Contact

Fill these fields in App Store Connect with real developer contact information before submission:

- First name: TBD
- Last name: TBD
- Phone: TBD
- Email: TBD

No demo account is required because Carry Splits has no authentication.

## Copyright

Use the legal developer/person or organization name associated with the App Store account, for example:

`2026 [LEGAL DEVELOPER OR ENTITY NAME]`
