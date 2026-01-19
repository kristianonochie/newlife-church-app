## iOS Release Guide (NewLife)

Building and publishing your Flutter app to the Apple App Store requires a Mac, Apple Developer account, and provisioning profiles.

### Prerequisites

- **Apple Developer Account** ($99/year) — enroll at https://developer.apple.com
- **Mac with Xcode** (Xcode 12+)
- **Provisioning Profile & Distribution Certificate** (created in Apple Developer)
- **Bundle ID** (reverse domain, e.g., `com.newlifechurch.app`)

### Step 1: Update iOS Bundle ID & Display Name

Edit `ios/Runner.xcodeproj/project.pbxproj` (or use Xcode):

- Set `PRODUCT_BUNDLE_IDENTIFIER` to your bundle ID (e.g., `com.newlifechurch.app`).
- Update `CFBundleDisplayName` in `ios/Runner/Info.plist` to `NewLife`.
- Update `CFBundleShortVersionString` (e.g., `1.0.0`) and `CFBundleVersion` (build number, e.g., `1`) in `Info.plist`.

Example `ios/Runner/Info.plist` snippet:
```xml
<key>CFBundleDisplayName</key>
<string>NewLife</string>
<key>CFBundleIdentifier</key>
<string>com.newlifechurch.app</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

Update version in `pubspec.yaml` to match (e.g., `version: 1.0.0+1`).

### Step 2: Create App Store Connect Entry

1. Go to https://appstoreconnect.apple.com
2. Click **+ App** and fill in:
   - App Name: `NewLife`
   - Bundle ID: `com.newlifechurch.app`
   - SKU: (unique identifier, e.g., `newlife-church-001`)
   - Platforms: iOS
3. Accept agreements and create.

### Step 3: Build & Archive on Mac

On a Mac, run:

```bash
flutter pub get
flutter build ios --release
```

Then open Xcode and create an archive:

```bash
open ios/Runner.xcworkspace
# In Xcode:
# 1. Select "Generic iOS Device" (top left)
# 2. Product → Archive
# 3. After archive completes, click "Distribute App"
# 4. Select "App Store Connect" and follow prompts
```

Or build IPA directly:

```bash
flutter build ipa --release
# Output: build/ios/ipa/Runner.ipa
# Upload via App Store Connect or Xcode
```

### Step 4: App Store Connect Submission

1. Go to your app on App Store Connect.
2. Click **Pricing and Availability** — set pricing tier and territories.
3. Fill in **App Information**:
   - App Icon (1024x1024 PNG)
   - Category: Lifestyle or Reference
   - Content rating: Complete questionnaire
4. Fill in **Version Release Information** (for version 1.0.0):
   - What's New: "Launch version — Daily devotions, Bible search, push notifications"
   - Screenshots (5 per device: iPhone 6.7", iPhone 5.5", iPad 12.9")
   - Preview Video (optional, 30 seconds)
   - Description: "NewLife is the official mobile app for New Life Community Church, Tonyrefail. Access daily devotions, search the Bible across multiple versions, receive notifications, and stay connected with our community."
   - Keywords: "church, devotion, bible, faith, prayer"
   - Support URL: https://www.newlifecc.co.uk
   - Privacy Policy URL: [your privacy policy URL]
   - App Review Information:
     - Test Account (if gated content): optional
     - Notes: "App is a community resource with no account required. Daily devotions and Bible verses are pre-loaded."

5. Scroll to **Build** and select your uploaded archive.
6. Click **Save**, then **Submit for Review**.
7. Apple reviews in 1–3 days. You'll receive email on approval or rejection.

### Step 5: Post-Launch Updates

To release version 1.0.1 or later:

1. Update `pubspec.yaml` version (e.g., `version: 1.0.1+2`).
2. Rebuild and archive on Mac.
3. Upload to App Store Connect.
4. Fill in new version notes and screenshots (if changed).
5. Submit for review again.

### Signing & Provisioning (Advanced)

If building on CI (GitHub Actions, Codemagic), you need to:

1. **Export signing credentials** from Mac (`ios/Runner.xcodeproj`):
   - Provisioning Profile (.mobileprovision)
   - Distribution Certificate (.p12, password-protected)

2. **Store securely** in CI secrets (GitHub Secrets, Codemagic, etc.).

3. **Configure Xcode build settings** in CI to use those credentials during archive.

Example GitHub Actions workflow (reference only):

```yaml
name: iOS Release Build
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build ipa --release
      - name: Upload to App Store
        run: |
          xcrun altool --upload-app \
            -f build/ios/ipa/Runner.ipa \
            -u ${{ secrets.APPLE_ID }} \
            -p ${{ secrets.APPLE_PASSWORD }} \
            -t ios \
            --output-format=xml
```

### Troubleshooting

- **"No signing certificate found"** — Ensure provisioning profile and certificate are installed on Mac.
- **"Build failed with code 1"** — Check Xcode build log and resolve any missing dependencies or framework conflicts.
- **"App rejected for policy violations"** — Review App Store Connect rejection reason and update accordingly.

### Resources

- Apple App Store Connect: https://appstoreconnect.apple.com
- Apple Developer: https://developer.apple.com
- Flutter iOS Build: https://flutter.dev/docs/deployment/ios
