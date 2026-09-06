# Carry Splits — Release Runbook

This runbook covers the first App Store release of Carry Splits 1.0.0.

## 1. Final Local Sync

From the repository root:

```bash
cd ~/Developer/CarrySplit
git pull origin main
```

Generate icon assets if they are not already present:

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

Regenerate the Xcode project after release-configuration changes:

```bash
xcodegen generate
open CarrySplits.xcodeproj
```

## 2. App Store Connect App Record

Before uploading the first build, create the app record in App Store Connect.

Use:

- Platform: iOS
- Name: Carry Splits
- Primary language: English (U.S.)
- Bundle ID: `com.m4ckdev.CarrySplits`
- SKU: `CARRYSPLITS-IOS-001`
- User access: Full Access unless a narrower account policy is desired

If the exact App Store name is unavailable, stop and decide the listing/display-name change before uploading a build.

## 3. Paid Apps Agreement

Because Carry Splits is a paid app, confirm the current Paid Apps Agreement is accepted in App Store Connect and that required tax/banking information is complete.

Do this before expecting the $1.99 price to be available for sale.

## 4. Pricing and Availability

In App Store Connect:

**Carry Splits → Monetization → Pricing and Availability**

- Add pricing
- Choose the desired base country/region
- Select the price point corresponding to **$1.99 USD** for the United States storefront
- Review Apple's automatically generated comparable prices for other storefronts
- Confirm availability regions

No in-app purchases or subscriptions are required.

## 5. App Information

Use `docs/APP_STORE_METADATA.md` as the source of truth.

Enter:

- Subtitle
- Categories
- Age-rating questionnaire
- Copyright
- Privacy Policy URL
- Optional accessibility information

Expected category direction:

- Primary: Finance
- Secondary: Travel

Expected age rating: 4+, subject to Apple's questionnaire result.

## 6. Privacy

In **App Privacy**:

- Provide the live public Privacy Policy URL
- Choose **No, we do not collect data from this app** if the shipping build still contains no data-collecting SDKs or services
- Confirm there is no tracking

The repository includes `PrivacyInfo.xcprivacy` declaring no tracking and no collected data types.

Do not change these answers if analytics, advertising, cloud sync, crash-reporting data collection, or other external SDKs are introduced without re-evaluating the privacy disclosure.

## 7. Accessibility

Use only labels supported by completed testing.

Simulator/manual evidence currently supports Larger Text, Dark Interface, differentiate-without-color behavior, and sufficient contrast.

VoiceOver should not be claimed until the common workflow is verified on a physical iPhone.

## 8. Screenshots

Use `docs/APP_STORE_SCREENSHOTS.md`.

Recommended v1.0 set: five portrait screenshots captured from a current 6.9-inch iPhone simulator.

App preview video: not required for v1.0.

## 9. Version Metadata

Release configuration:

- Marketing version: `1.0.0`
- Build number: `1`

For every additional upload of version 1.0.0, increment the build number before archiving again.

Example:

- First upload: 1.0.0 (1)
- Replacement upload: 1.0.0 (2)
- Next replacement: 1.0.0 (3)

Never reuse an already uploaded build number for the same version.

## 10. Final Xcode Checks

In Xcode:

1. Select the `CarrySplits` target.
2. Confirm the Apple Developer Team.
3. Confirm bundle ID `com.m4ckdev.CarrySplits`.
4. Confirm version/build values.
5. Run the full test suite.
6. Confirm no release-blocking warnings.
7. Perform the remaining physical-iPhone and VoiceOver checks before final App Review submission.

## 11. Archive

In Xcode, select a generic physical-device destination such as **Any iOS Device (arm64)** rather than an iPhone Simulator.

Then choose:

**Product → Archive**

When the archive completes, Xcode Organizer opens.

## 12. Validate and Upload

In Organizer:

1. Select the Carry Splits archive.
2. Click **Distribute App**.
3. Choose **App Store Connect**.
4. Choose **Upload**.
5. Allow Xcode to manage signing unless a specific manual-signing policy is required.
6. Review validation results.
7. Upload the build.

The build must process in App Store Connect before it can be selected for TestFlight or App Review.

## 13. TestFlight

After processing:

1. Open Carry Splits → TestFlight.
2. Select build 1.0.0 (1).
3. Complete any required compliance fields.
4. Add the developer's internal tester account.
5. Install from TestFlight on a physical iPhone.
6. Repeat the release-critical workflow:
   - create split
   - add participants
   - equal expense
   - exact expense
   - settlement
   - share
   - terminate/relaunch persistence
   - offline operation
   - Dark Mode
   - large text
   - VoiceOver
7. Fix any release blocker and upload a new build number if needed.

## 14. Version Page

For iOS version 1.0.0, enter the metadata from `docs/APP_STORE_METADATA.md`:

- screenshots
- description
- keywords
- support URL
- promotional text (optional but prepared)
- App Review contact
- App Review notes

Select the processed build in the **Build** section.

## 15. App Review

Before pressing Submit for Review, verify:

- live Privacy Policy URL
- live Support URL with actual contact information
- Paid Apps Agreement/tax/banking complete
- $1.99 pricing configured
- screenshots uploaded
- privacy answers complete
- age rating complete
- review contact complete
- build selected
- no unresolved export-compliance question
- no physical-device release blocker

Then submit the version to App Review.

## 16. Release Strategy

For v1.0, use **Manual Release** unless there is a specific reason to launch automatically immediately after approval.

Manual release provides one final checkpoint after Apple approves the binary and metadata.

## 17. Post-Approval

After approval and release:

- verify the live App Store product page
- verify price in the U.S. storefront
- verify screenshots and description
- purchase/download using a non-development account if practical
- verify first production launch
- tag the release commit, for example `v1.0.0`
- update `CHANGELOG.md`
- begin collecting only direct user feedback; do not add analytics to v1.0 without a deliberate privacy review
