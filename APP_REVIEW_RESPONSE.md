# App Store Review Response Template

## Response to App Review Team - Submission ID: a0eda296-9de8-4a8b-af0a-37316f7d37b0

---

### Dear App Review Team,

Thank you for your detailed feedback on our submission. We have addressed all four issues identified in your review dated January 31, 2026. Please see our responses below:

---

## 1. Guideline 2.3.3 - Performance - Accurate Metadata (Screenshots)

**Issue**: iPad screenshots showed iPhone device frames, and Apple Watch screenshots only displayed splash screens.

**Resolution**: 
- We have removed all Apple Watch screenshots from our submission
- We have uploaded new iPad screenshots showing the actual app interface on iPad devices
- All screenshots now accurately reflect the app's UI on the correct device type
- Screenshots have been updated to show the app's core features: Daily Devotions, Bible Search, Events, Prayer Requests, and Community features

**Action Taken**: Replaced all screenshots in Media Manager with device-appropriate captures showing actual app functionality.

---

## 2. Guideline 2.1 - Performance - App Completeness (Donation Payment Bug)

**Issue**: The app displayed an error when attempting to make a donation payment.

**Resolution**:
- Enhanced error handling in the donation/giving feature with comprehensive try-catch blocks
- Improved user feedback with clear error messages and fallback instructions
- Added loading indicators to show users the app is processing their request
- Implemented graceful fallback directing users to our website if PayPal redirect fails
- All donation buttons now redirect to PayPal's secure external donation page (hosted_button_id: V56HCXFE46U5E)

**Technical Details**:
- The app uses url_launcher with `LaunchMode.externalApplication` to open PayPal in the device's default browser
- This approach complies with App Store guidelines by not processing payments within the app
- Users are clearly informed that they will be redirected to a browser to complete their donation
- Error states now provide alternative contact methods (website URL and email)

**Testing**: We have tested the donation flow on multiple iOS devices and simulators with successful PayPal redirects.

---

## 3. Guideline 2.3.10 - Performance - Accurate Metadata (Non-iOS Device Images)

**Issue**: iPhone 6.5" and 6.7" screenshots included non-iOS device images.

**Resolution**:
- All screenshots have been replaced with iOS-only captures
- Removed any Android device frames or references
- Screenshots now show pure iOS interface without device mockups
- Updated all size variants (6.5", 6.7", and iPad) with iOS-native screenshots

**Action Taken**: Completely refreshed screenshot library in App Store Connect Media Manager.

---

## 4. Guideline 2.1 - Information Needed (Demo Account Credentials)

**Issue**: Unable to sign in with provided demo account credentials.

**Clarification**:
**This app does NOT require user authentication or login.** All features are publicly accessible without creating an account or signing in. 

The demo credentials were provided in error during submission. We apologize for the confusion.

**App Features (No Login Required)**:
- ✅ Daily Devotions - Accessible immediately upon app launch
- ✅ Bible Search - Open to all users with multiple translations
- ✅ Events & Service Times - Public information viewable by all
- ✅ Prayer Requests - Submission form available to all users (no account needed)
- ✅ About Church - Public information about New Life Community Church
- ✅ Contact - Direct communication via email/form (no login)
- ✅ Give/Donate - External PayPal redirect (no account needed in app)

**Testing Instructions for Reviewers**:
You can test all app features without logging in. Simply:
1. Launch the app
2. Navigate through the bottom navigation bar to explore all screens
3. Test devotions by tapping on any devotion card
4. Search for Bible verses using the search field
5. Submit a prayer request via the form
6. Test donation buttons (they will redirect to PayPal in browser)

**Note**: There is no "Sign In" or "Create Account" screen in this app. All content is open and free to access.

---

## Additional Information

### App Version Details:
- **Version**: 1.0 (Build 1)
- **Platform**: iOS 13.0+, iPadOS 13.0+
- **Frameworks**: Flutter 3.x
- **Primary Language**: English

### Privacy & Data:
- No user authentication or account creation
- No in-app payments (all donations external via PayPal)
- Limited data collection (Firebase Analytics for crash reporting only)
- Full privacy policy available in-app and at: [Your Privacy Policy URL]

### Contact Information:
If you have any questions or need additional information, please don't hesitate to contact us:
- **Email**: kristianonochie@gmail.com
- **Phone**: [Your Contact Number]
- **Website**: www.newlifetonyrefail.co.uk

---

## Summary of Changes Made:

✅ **Screenshots**: Completely replaced with iOS-only, device-appropriate images  
✅ **Donation Feature**: Enhanced error handling and user feedback  
✅ **Metadata Accuracy**: Removed non-iOS references from all screenshots  
✅ **Demo Credentials**: Clarified that no login is required - app is fully accessible  

We believe these changes fully address all concerns raised in your review. The app now provides a clear, accurate representation of its features and functionality for iOS users.

Thank you for your time and thorough review. We appreciate the App Store team's commitment to quality and user experience.

**Respectfully submitted,**

New Life Community Church, Tonyrefail  
Developer: Christian Onochie  
Date: February 2, 2026

---

## How to Submit This Response:

1. Log in to **App Store Connect**
2. Go to **My Apps** → Select your app
3. Click on the version **1.0** in review
4. Scroll to **App Review Information**
5. Click **"Reply to App Review"** or **"Respond to Reviewer Notes"**
6. Copy and paste the relevant sections above
7. Keep it concise - focus on the 4 main issues
8. Upload new screenshots in Media Manager BEFORE responding
9. Click **Submit** to send response and resubmit for review

---

### Shorter Version (If Character Limit Applies):

```
Dear App Review Team,

Thank you for your feedback. We have addressed all four issues:

1. **Screenshots (2.3.3 & 2.3.10)**: Replaced all screenshots with iOS-only captures showing actual app features on correct devices. Removed Apple Watch screenshots entirely.

2. **Donation Bug (2.1)**: Enhanced error handling in giving feature. PayPal redirect now includes loading indicators and graceful fallback messages if redirect fails. Tested successfully on iOS devices.

3. **Demo Account (2.1)**: This app does NOT require login. All features (devotions, Bible search, events, prayer requests, donations) are publicly accessible. No account creation needed. Simply launch the app and test all features via bottom navigation.

We have tested all functionality on iPhone 17 Pro Max and iPad Air simulators. All issues are resolved.

Thank you,
Christian Onochie
New Life Community Church
```

---

*Created: February 2, 2026*
*Submission ID: a0eda296-9de8-4a8b-af0a-37316f7d37b0*
