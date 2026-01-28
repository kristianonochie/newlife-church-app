# App Store Compliance Checklist and Resubmission Recommendations

## Compliance Checklist (Guidelines 2.3.3, 2.3.10, 3.2.2)

### Guideline 2.3.3 – Accurate Metadata
- [x] App name, description, and screenshots accurately reflect the app’s features and content.
- [x] No hidden, misleading, or unlisted features in the app or codebase.
- [x] Privacy policy is present in-app and matches the App Store Connect listing.
- [x] All features described in the App Store listing are available in the app.

### Guideline 2.3.10 – Review/Rating Prompts
- [x] No custom review, rate, or feedback prompts in the app.
- [x] No use of unofficial review APIs or packages (e.g., in_app_review).
- [x] No dialogs or popups requesting reviews or ratings outside of Apple’s official API.

### Guideline 3.2.2 – Data Use & Privacy
- [x] Privacy policy is accessible in-app and via a public URL.
- [x] Policy clearly discloses all data collection, storage, and sharing practices.
- [x] User rights (access, rectification, erasure) are explained.
- [x] No unauthorized analytics, tracking, or data sharing.
- [x] Payment/donation features are removed or disabled for iOS/App Store builds.
- [x] Firebase and local storage usage is disclosed in the privacy policy.

---

## App Store Resubmission Recommendations

1. **Review App Store Connect Metadata**
   - Double-check that your app name, description, keywords, and screenshots match the current app features and UI.
   - Ensure the privacy policy URL is correct and matches the in-app policy.

2. **Privacy Policy**
   - Confirm the privacy policy is accessible both in-app and via the public URL.
   - Make sure it clearly explains all data collection, storage, and user rights.

3. **Remove/Disable Non-Compliant Features**
   - Ensure all payment/donation features are removed or disabled for iOS.
   - Confirm no custom review/rating prompts are present.

4. **Testing**
   - Test the app on a real iOS device to verify all features work as described and no hidden features exist.
   - Check that the privacy policy is accessible from the app’s main menu or settings.

5. **Submission Notes**
   - In the App Store Connect “App Review Notes,” briefly explain that you have addressed guidelines 2.3.3, 2.3.10, and 3.2.2.
   - Mention that all review prompts use only Apple’s official APIs (if any), and that the privacy policy is fully disclosed and accessible.

6. **Final Checklist**
   - Increment the app version/build number before resubmitting.
   - Rebuild and archive the app for release.
   - Submit for review and monitor for feedback.

---

### App Review Notes Template

> Dear App Review Team,
>
> This submission addresses the previous feedback regarding guidelines 2.3.3, 2.3.10, and 3.2.2:
> - All app metadata and screenshots accurately reflect the app’s features and content.
> - No custom review/rating prompts are present; only Apple’s official APIs are used (if any).
> - The privacy policy is accessible in-app and via the provided URL, and fully discloses all data practices.
> - Payment/donation features are removed/disabled for iOS.
>
> Please let us know if further clarification is needed.

---

*Prepared: January 28, 2026*
