# Admin Dashboard with Analytics - Complete Guide

## Overview

Your New Life Church app now has a complete admin dashboard with:
- **Analytics Tab** - Monitor app usage, track features, view statistics
- **Notifications Tab** - Send push notifications to all users

---

## Accessing the Admin Dashboard

### Login Credentials:
- **URL**: Open app → Drawer menu → "Admin"
- **Username**: `nlccapp`
- **Password**: `Nlccapp@2026`

---

## Features

### 📊 Analytics Tab

#### 1. **Key Statistics Cards**
- **Total Sessions**: Number of times the app has been opened
- **Days Active**: Days since app was first installed
- **Total Events**: All interactions tracked (button clicks, page views, etc.)
- **Top Feature**: Most popular feature being used

#### 2. **Top 5 Most Used Features**
Visual bar chart showing:
- Feature names (Bible, Prayer, Devotion, etc.)
- Usage count for each feature
- Progress bars showing relative popularity

#### 3. **App Information**
- Installation date
- Tracking status
- Data storage location

### 📢 Notifications Tab

#### Send Notifications To:
1. **All Users** - Broadcast to everyone
2. **Announcements** - General church announcements
3. **Devotions** - Daily devotion updates
4. **Events** - Event notifications
5. **Prayer** - Prayer request updates

#### Form Fields:
- **Title** - Notification headline (max 50 characters)
- **Message** - Notification body (max 200 characters)
- **Send Button** - Instant delivery to all subscribed devices

---

## How Analytics Work

### Automatic Tracking

The app automatically tracks:

1. **App Opens** (`session_start`)
   - Every time the app is launched
   - Session count increments

2. **Screen Views** (`screen_view`)
   - When user visits any page
   - Tracks: Home, Bible, Prayer, Give, etc.

3. **Feature Usage** (`feature_used`)
   - When specific features are used
   - Examples:
     - Bible search
     - Prayer submission
     - Giving transactions
     - Chat messages

### Data Storage

**Current Setup** (Local Storage):
- Analytics stored on admin's device only
- Uses `SharedPreferences`
- Shows stats for this device's usage
- Perfect for testing and single-user tracking

**Production Setup** (Global Analytics):
- Requires Firebase Analytics
- Tracks all users across all devices
- Real-time dashboard in Firebase Console
- See setup instructions below

---

## Feature Tracking Points

The app tracks these features:

| Feature | Triggered When |
|---------|---------------|
| `home` | Home screen visited |
| `devotion` | Devotion page opened |
| `bible` | Bible page opened |
| `bible_search` | User searches for a verse |
| `bible_favorite` | User favorites a verse |
| `events` | Events page visited |
| `prayer` | Prayer page opened |
| `prayer_submit` | Prayer request submitted |
| `give` | Give page opened |
| `give_offering` | Offering donation initiated |
| `give_tithe` | Tithe donation initiated |
| `give_support` | Support donation initiated |
| `give_firstfruits` | First fruits donation initiated |
| `nlcchat` | Chat page opened |
| `nlcchat_message` | Message sent in chat |
| `about` | About page visited |
| `contact` | Contact page visited |
| `notifications` | Notifications page opened |

---

## Upgrading to Global Analytics

### Current Limitation:
Analytics show only **this device's** usage because data is stored locally.

### To Track All Users Globally:

#### Option 1: Firebase Analytics (Recommended)

1. **Enable Firebase Analytics**
   ```bash
   flutter pub add firebase_analytics
   ```

2. **Initialize in main.dart**
   ```dart
   import 'package:firebase_analytics/firebase_analytics.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     
     // Initialize analytics
     FirebaseAnalytics analytics = FirebaseAnalytics.instance;
     
     runApp(MyApp());
   }
   ```

3. **Update analytics_service.dart**
   - Replace `SharedPreferences` calls with `FirebaseAnalytics`
   - Send events to Firebase instead of local storage

4. **View in Firebase Console**
   - Go to: console.firebase.google.com
   - Select your project
   - Click "Analytics" in left menu
   - See real-time users, events, and more

#### Option 2: Custom Backend

1. Create a Node.js/Python backend
2. Add endpoint: `POST /api/analytics/track`
3. Store events in PostgreSQL/MongoDB
4. Create custom dashboard to visualize data

---

## Notification System Setup

### Prerequisites:
1. Firebase project configured
2. FCM Server Key obtained (see FIREBASE_FCM_ADMIN_SETUP.md)
3. All app users subscribed to topics (automatic on app launch)

### Sending a Notification:

1. **Login to Admin Dashboard**
2. **Switch to "Send Notification" tab**
3. **Select recipient group** (All Users, Announcements, etc.)
4. **Enter title** (e.g., "Sunday Service Reminder")
5. **Enter message** (e.g., "Join us tomorrow at 10:30 AM!")
6. **Click "Send Notification"**
7. **Wait for confirmation**: "✓ Notification sent successfully!"

### Notification Delivery:
- **Instant** - Delivered within seconds
- **All platforms** - Android, iOS, Web
- **Works when**: App is open, in background, or closed
- **Requires**: User has notifications enabled on their device

---

## Analytics Dashboard Examples

### Example 1: Weekly Report
```
Total Sessions: 45
Days Active: 7
Total Events: 234
Top Feature: Bible Search (67 uses)

Top 5 Features:
1. Bible Search - 67 uses
2. Prayer Submit - 34 uses  
3. Devotion - 28 uses
4. NLCChat - 19 uses
5. Give - 12 uses
```

### Example 2: New User
```
Total Sessions: 1
Days Active: 0
Total Events: 5
Top Feature: Home (1 use)

Top 5 Features:
1. Home - 1 use
2. Bible - 1 use
3. Prayer - 1 use
4. About - 1 use
5. Events - 1 use
```

---

## Troubleshooting

### "No usage data yet"
- **Cause**: App just installed, no features used yet
- **Solution**: Use the app features (Bible search, Prayer, etc.)
- Analytics will update within seconds

### Notification "Failed to send"
- **Cause**: FCM server key not configured
- **Solution**: 
  1. Get FCM key from Firebase Console
  2. Update `lib/services/admin_service.dart`
  3. Replace `YOUR_FCM_SERVER_KEY_HERE` with actual key

### Analytics not updating
- **Cause**: Analytics service not initialized
- **Solution**: Close and reopen the app
- Check that `AnalyticsService().init()` is called in `main.dart`

### Can't see other users' data
- **Expected**: Current version tracks local device only
- **Solution**: Implement Firebase Analytics (see "Upgrading to Global Analytics")

---

## Security Notes

### Admin Password:
- Current: `Nlccapp@2026`
- **Change in production**: Edit `lib/services/admin_service.dart`
- Line 7-8: Update `_username` and `_password` constants

### FCM Server Key:
- Currently embedded in app code
- **Better approach**: Move to backend server
- Store as environment variable, not in app code

### Admin Access:
- Anyone with credentials can access admin panel
- Consider adding:
  - Multi-factor authentication
  - IP whitelist
  - Audit logging of admin actions

---

## Future Enhancements

### Suggested Features:
1. **Scheduled Notifications**
   - Send notifications at specific date/time
   - Recurring notifications (weekly reminders)

2. **Notification History**
   - See all sent notifications
   - Resend previous notifications
   - Delete/edit sent notifications

3. **User Segments**
   - Target by location
   - Target by age group
   - Target by ministry involvement

4. **Advanced Analytics**
   - User retention rate
   - Daily active users (DAU)
   - Weekly active users (WAU)
   - Conversion funnels
   - User journey maps

5. **A/B Testing**
   - Test different notification messages
   - Measure engagement rates
   - Optimize conversion

6. **Export Reports**
   - Download analytics as CSV/PDF
   - Email weekly reports
   - Generate charts/graphs

---

## Technical Details

### Files Modified/Created:

1. **`lib/services/analytics_service.dart`** - NEW
   - Tracks all app events
   - Stores data locally
   - Provides aggregated statistics

2. **`lib/services/admin_service.dart`** - NEW
   - Admin authentication
   - FCM notification sending
   - Topic-based messaging

3. **`lib/screens/admin/admin_login_screen.dart`** - NEW
   - Admin login form
   - Username/password validation

4. **`lib/screens/admin/admin_dashboard_screen.dart`** - NEW
   - Analytics tab with charts
   - Notifications tab with form
   - Two-tab interface

5. **`lib/routes/app_routes.dart`** - UPDATED
   - Added `/admin` route
   - Added `/admin/dashboard` route

6. **`lib/widgets/app_drawer.dart`** - UPDATED
   - Added "Admin" menu item

7. **`lib/main.dart`** - UPDATED
   - Initialize analytics on app start

8. **`lib/services/notification_service_mobile.dart`** - UPDATED
   - Subscribe users to FCM topics

---

## Next Steps

1. ✅ **Test Admin Login**
   - Open drawer → Admin
   - Login with credentials
   - Verify dashboard loads

2. ✅ **Use App Features**
   - Navigate to different pages
   - Search Bible verses
   - Submit prayer request
   - Check analytics update

3. ⚠️ **Configure FCM** (for notifications)
   - Get server key from Firebase
   - Update `admin_service.dart`
   - Test sending notification

4. ⚠️ **Deploy to Production**
   - Change admin password
   - Enable Firebase Analytics
   - Set up backend for global tracking

---

## Support & Documentation

- **Firebase FCM Setup**: FIREBASE_FCM_ADMIN_SETUP.md
- **Email**: nlccapp@newlifecc.co.uk
- **Firebase Console**: https://console.firebase.google.com
- **Analytics Docs**: https://firebase.google.com/docs/analytics

---

**Last Updated**: January 14, 2026
**Version**: 1.0.0
**Author**: NLCC Tech Team
