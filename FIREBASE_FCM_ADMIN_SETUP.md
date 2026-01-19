# Firebase Cloud Messaging (FCM) Setup for Admin Notifications

This guide explains how to set up Firebase Cloud Messaging so the admin dashboard can send push notifications to all app users.

## Prerequisites

- Firebase project created (from initial app setup)
- Firebase Cloud Messaging enabled
- App already configured with Firebase (firebase_core and firebase_messaging packages)

---

## Step 1: Get Your FCM Server Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **New Life Church App**
3. Click the **gear icon** (⚙️) → **Project settings**
4. Navigate to the **Cloud Messaging** tab
5. Under **Cloud Messaging API (Legacy)**, find **Server key**
6. Click **Show** or **Copy** to get the server key
   - It will look like: `AAAAxxxxxxx:APA91bF...` (very long string)

### Important Note:
If you see "Cloud Messaging API (Legacy) is disabled", you need to:
- Click **Enable Cloud Messaging API (Legacy)** button
- OR use the newer **FCM HTTP v1 API** (more complex, see Step 5)

---

## Step 2: Add Server Key to AdminService

1. Open: `lib/services/admin_service.dart`
2. Find this line:
   ```dart
   final String _fcmServerKey = 'YOUR_FCM_SERVER_KEY_HERE';
   ```
3. Replace with your actual server key:
   ```dart
   final String _fcmServerKey = 'AAAAxxxxxxx:APA91bF...your-key-here';
   ```

---

## Step 3: Test the Admin System

### Login Credentials:
- **Username**: `nlccapp`
- **Password**: `Nlccapp@2026`

### Testing Flow:
1. **Open the app**
2. **Open drawer menu** → Click **Admin**
3. **Login** with credentials above
4. **Admin Dashboard** will open
5. **Send a test notification:**
   - Select "All Users"
   - Title: "Test Notification"
   - Message: "This is a test from the admin panel"
   - Click **Send Notification**

6. **Check if notification was sent:**
   - You should see "✓ Notification sent successfully!" message
   - If you see "❌ Failed to send notification", check:
     - FCM server key is correct
     - Cloud Messaging API is enabled in Firebase
     - Internet connection is active

---

## Step 4: Topic Subscriptions

The app automatically subscribes all users to these topics when they open the app:

| Topic Name | Purpose |
|-----------|---------|
| `all_users` | Admin broadcast to everyone |
| `announcements` | General church announcements |
| `devotions` | Daily devotion updates |
| `events` | Event notifications |
| `prayer` | Prayer request updates |

### How it works:
1. User opens app → `NotificationService.init()` is called
2. Service subscribes user to all topics via FCM
3. Admin sends notification to a topic (e.g., "all_users")
4. FCM delivers notification to all subscribed devices
5. Notification appears on user's device

---

## Step 5: Alternative - FCM HTTP v1 API (Advanced)

If Legacy API is not available, use the newer HTTP v1 API:

### Setup:
1. In Firebase Console → **Project Settings** → **Service Accounts**
2. Click **Generate New Private Key**
3. Save the JSON file securely
4. Update `AdminService` to use OAuth 2.0 authentication (requires additional packages)

### Code changes needed:
```dart
// Install googleapis_auth package
dependencies:
  googleapis_auth: ^1.4.1

// Use service account to get access token
// Then send to: https://fcm.googleapis.com/v1/projects/YOUR-PROJECT-ID/messages:send
```

**Note**: Legacy API is simpler and recommended for this use case.

---

## Step 6: Security Best Practices

### ⚠️ Important Security Notes:

1. **Server Key Protection:**
   - The server key in `admin_service.dart` is embedded in the app
   - This is acceptable for internal church use
   - For production apps with untrusted users, move the server key to a backend server

2. **Better Production Approach:**
   - Create a backend endpoint (Node.js, Python, etc.)
   - Store FCM server key on the backend (environment variable)
   - Admin app calls your backend, backend calls FCM
   - Example:
     ```
     Admin App → Your Backend API → FCM Servers → User Devices
     ```

3. **Admin Password:**
   - Current password: `Nlccapp@2026`
   - Change in production: `lib/services/admin_service.dart`
   - Consider using Firebase Authentication for admin login (more secure)

---

## Step 7: Notification Delivery Testing

### Test on Different Platforms:

#### Android:
- Notifications work when app is in **foreground**, **background**, or **closed**
- No special configuration needed

#### iOS:
- Requires **Apple Developer Account** and **APNs certificate**
- Configure in Firebase Console → **Cloud Messaging** → **APNs Certificates**
- Upload your `.p8` authentication key or `.p12` certificate
- See [Firebase iOS setup](https://firebase.google.com/docs/cloud-messaging/ios/client)

#### Web:
- Requires **Web Push Certificates** (VAPID keys)
- Configure in Firebase Console → **Cloud Messaging** → **Web Push certificates**
- Generate key pair and add to your app

---

## Troubleshooting

### "Failed to send notification" Error:

1. **Check FCM Server Key:**
   ```dart
   // Verify in admin_service.dart:
   final String _fcmServerKey = 'AAAA...'; // Must start with AAAA
   ```

2. **Verify Cloud Messaging is enabled:**
   - Firebase Console → Cloud Messaging tab
   - Ensure API is enabled

3. **Check network connection:**
   - Admin dashboard requires internet to send notifications
   - FCM endpoint: `https://fcm.googleapis.com/fcm/send`

4. **Inspect browser console (Web) or logs (Mobile):**
   ```bash
   flutter run -d edge
   # Watch for: "Error sending notification: ..."
   ```

### "Notification not received on device"

1. **Verify topic subscription:**
   - App must be opened at least once to subscribe
   - Check logs for: "Subscribed to notification topics"

2. **Check device notification permissions:**
   - Android: Settings → Apps → New Life Church → Notifications → Enabled
   - iOS: Settings → New Life Church → Notifications → Allow Notifications

3. **Test with device token directly:**
   - Get FCM token from app (logged on init)
   - Use Firebase Console → Cloud Messaging → Send test message
   - Paste device token to test delivery

---

## Usage Examples

### Send Weekly Announcement:
```
Topic: All Users
Title: Sunday Service This Week
Message: Join us this Sunday at 10:30 AM for worship and fellowship. Guest speaker: Pastor John Smith.
```

### Send Devotion Reminder:
```
Topic: Devotions
Title: New Devotion Available
Message: Today's devotion: "Walking in Faith". Read now in the app!
```

### Send Event Alert:
```
Topic: Events
Title: Youth Night - Friday 7 PM
Message: All youth invited for games, worship, and pizza! Don't miss it.
```

---

## Admin Dashboard Features

✅ **Login System** - Secure admin access
✅ **Topic Selection** - Send to specific groups
✅ **Message Composer** - Title + message fields
✅ **Instant Delivery** - Notifications sent immediately
✅ **Success Feedback** - Visual confirmation of sent messages
✅ **Mobile Responsive** - Works on all screen sizes

---

## Next Steps

1. ✅ Complete Firebase FCM setup (get server key)
2. ✅ Update `admin_service.dart` with your FCM server key
3. ✅ Test admin login and notification sending
4. ✅ Send test notification to yourself
5. ✅ Train church admin on using the dashboard
6. ⚠️ (Optional) Move FCM key to backend server for production
7. ⚠️ (Optional) Add notification scheduling feature
8. ⚠️ (Optional) Add notification history/analytics

---

## Support

For issues or questions:
- 📧 Email: nlccapp@newlifecc.co.uk
- 📖 Firebase Docs: https://firebase.google.com/docs/cloud-messaging
- 🔧 Flutter FCM Package: https://pub.dev/packages/firebase_messaging

---

**Last Updated:** January 14, 2026
**App Version:** 1.0.0
