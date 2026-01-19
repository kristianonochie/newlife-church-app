## Release Checklist (NewLife App)

Use this checklist before submitting to Play Store or App Store.

### Code & Build Verification

- [ ] Run `flutter analyze` — no critical errors
- [ ] Run `flutter test` — all tests pass
- [ ] Update `pubspec.yaml` version (e.g., `1.0.0+1` for v1.0.0, build 1)
- [ ] Update version in `ios/Runner/Info.plist` (CFBundleShortVersionString, CFBundleVersion)
- [ ] Update app name and description in `pubspec.yaml`
- [ ] Test on Android emulator / device — full user flow
- [ ] Test on iOS simulator / device (if available) — full user flow
- [ ] Verify Firebase config is set for production (not debug)
- [ ] Check for hardcoded debug URLs or API keys — remove or use env vars

### Android Release (Play Store)

- [ ] Generate keystore (if not done):
  ```
  .\scripts\generate_keystore.ps1
  ```
- [ ] Create `android/keystore.properties` with real passwords (do NOT commit)
- [ ] Build AAB:
  ```
  flutter build appbundle --release
  ```
- [ ] Test AAB locally with bundletool (optional but recommended)
- [ ] Create Play Store app listing (https://play.google.com/console)
- [ ] Upload AAB to internal testing, verify on test device
- [ ] Add store listing metadata:
  - [ ] App icon (512x512 PNG)
  - [ ] Screenshots (4–6 per device type)
  - [ ] Feature graphic (1024x500 PNG)
  - [ ] App description (max 4000 chars)
  - [ ] Short description (max 80 chars)
  - [ ] Category & content rating (complete questionnaire)
- [ ] Set privacy policy URL
- [ ] Accept developer agreement & policies
- [ ] Submit for review (1–7 days)

### iOS Release (App Store)

- [ ] Mac with Xcode available (or CI/CD setup)
- [ ] Apple Developer account ($99/year)
- [ ] Update bundle ID in `ios/Runner/Info.plist`
- [ ] Update version in `ios/Runner/Info.plist`
- [ ] Build IPA on Mac:
  ```
  flutter build ipa --release
  ```
- [ ] Create App Store Connect app (https://appstoreconnect.apple.com)
- [ ] Upload archive to App Store Connect
- [ ] Add app store listing metadata:
  - [ ] App icon (1024x1024 PNG)
  - [ ] Screenshots (5 per device size: iPhone 6.7", 5.5", iPad)
  - [ ] App description (max 4000 chars)
  - [ ] Keywords (max 100 chars, comma-separated)
  - [ ] Category & content rating
- [ ] Set support & privacy policy URLs
- [ ] Submit for review (1–3 days)

### Web Release (Optional - Firebase Hosting)

- [ ] Build web:
  ```
  flutter build web --release
  ```
- [ ] Configure Firebase hosting:
  ```
  firebase init hosting
  firebase deploy --only hosting
  ```
- [ ] Verify site loads at https://[project].web.app

### Pre-Submission Marketing/Support

- [ ] Privacy policy URL is live and current
- [ ] Support email / contact form is working
- [ ] Social links (if any) are correct
- [ ] Screenshots are high-quality, in-app (not mock-ups unless specified)
- [ ] Test account provided to reviewers (if gated content exists)

### Post-Launch Monitoring

- [ ] Monitor app reviews / ratings
- [ ] Check crash reports (Android Play Console, App Store Connect)
- [ ] Respond to user feedback
- [ ] Plan for version updates and bug fixes

### Version Numbering

Follow semantic versioning + build number:

- `pubspec.yaml`: `version: MAJOR.MINOR.PATCH+BUILD`
  - Example: `1.0.0+1` (v1.0.0, build 1)
  - Increment BUILD for every submission
  - Increment PATCH for bug fixes (v1.0.1+2)
  - Increment MINOR for new features (v1.1.0+3)
  - Increment MAJOR for breaking changes (v2.0.0+4)

### Rollout Strategy

1. **Internal Testing** (first 1–2 days)
   - Submit to internal test track
   - Verify on 2–3 test devices
   - Check for crashes, UI issues, missing content

2. **Staged Rollout** (optional, first week)
   - 5% of users → 25% → 100%
   - Monitor crash rate and reviews at each stage

3. **Full Release**
   - Once stable and positive reviews, roll out to 100%

### Emergency Rollback

If critical issues are discovered post-launch:

1. **Android**: Unpublish current version, roll back to prior version if available
2. **iOS**: Contact Apple support for emergency review if critical security issue

---

**Last Updated:** January 6, 2026
**App:** NewLife (New Life Community Church, Tonyrefail)
