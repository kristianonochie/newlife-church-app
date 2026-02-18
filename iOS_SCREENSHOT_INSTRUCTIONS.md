# iOS Screenshot Capture Instructions for App Store

## 🚨 CRITICAL: App Store Rejection Issues to Fix

Your app was rejected for screenshot issues:
1. ❌ iPad screenshots showed iPhone device frames
2. ❌ Apple Watch screenshots only showed splash screens  
3. ❌ iPhone screenshots showed Android devices

**You MUST capture iOS-only screenshots using the methods below.**

---

## 📱 Method 1: Using Web Platform (Temporary Solution)

Since you're on Windows without access to iOS simulators, you can capture initial screenshots from the web version and later replace them with iOS-native captures.

### Step 1: Run the App
```bash
flutter run -d edge --web-port=8080
```

### Step 2: Open Browser Developer Tools
1. Press `F12` in Edge/Chrome
2. Click the **Device Toolbar** icon (phone/tablet icon) or press `Ctrl+Shift+M`
3. Select device: **iPhone 14 Pro Max** (430 x 932px)

### Step 3: Navigate and Capture
Navigate to each screen using the bottom navigation:
1. **Home Screen** - http://localhost:8080
2. **Devotions** - Click "Devotions" in bottom nav
3. **Bible** - Click "Bible" in bottom nav
4. **Events** - Click "Events" in bottom nav
5. **About** - Click "About" in bottom nav
6. **Prayer** - Click "Prayer" in bottom nav
7. **Give** - Click "Give" in bottom nav

### Step 4: Take Screenshots
- Press `Ctrl+Shift+P` (Windows) or `Cmd+Shift+P` (Mac)
- Type "Capture screenshot"
- Select "Capture full size screenshot"
- Save as: `screenshot_1_home.png`, `screenshot_2_devotions.png`, etc.

### Step 5: Resize for App Store
Use an online tool to resize to exact App Store dimensions:
- **iPhone 6.7"**: 1290 x 2796 px
- **iPhone 6.5"**: 1242 x 2688 px  
- **iPad 12.9"**: 2048 x 2732 px

**Free Resize Tools**:
- https://www.photopea.com (free Photoshop alternative)
- https://www.befunky.com/create/resize-image/
- https://imageresizer.com

---

## 📱 Method 2: Using Online iOS Mockup Generators (RECOMMENDED)

These services create iOS-native looking screenshots:

### Option A: Screenshots.pro
1. Go to https://screenshots.pro
2. Upload your web screenshots
3. Select "iPhone 14 Pro Max" frame
4. Download iOS-styled images

### Option B: App Mockup
1. Go to https://app-mockup.com
2. Upload screenshots
3. Choose iOS device frames
4. Export in App Store sizes

### Option C: Appure.io
1. Go to https://appure.io
2. Create free account
2. Upload screenshots
3. Generate App Store-ready images

---

## 📱 Method 3: Using Mac with Xcode (BEST - Requires Mac Access)

If you have access to a Mac or can borrow one:

### Step 1: Install Xcode
```bash
# On Mac terminal
xcode-select --install
```

### Step 2: Open iOS Simulator
```bash
# List available simulators
xcrun simctl list devices

# Boot iPhone 14 Pro Max
xcrun simctl boot "iPhone 14 Pro Max"

# Or use Xcode GUI:
# Xcode → Open Developer Tool → Simulator
```

### Step 3: Run Flutter App
```bash
flutter run -d "iPhone 14 Pro Max"
```

### Step 4: Capture Screenshots
In Simulator:
- Navigate to each screen
- Press `Cmd+S` to save screenshot
- Screenshots save to Desktop automatically

For iPad:
```bash
flutter run -d "iPad Air (5th generation)"
```

### Step 5: Verify Sizes
App Store requires:
- **iPhone 6.7"** (Pro Max): 1290 x 2796 px
- **iPhone 6.5"** (Plus): 1242 x 2688 px
- **iPad Pro 12.9"**: 2048 x 2732 px

---

## 🎯 Screenshot Sequence (7-8 Screenshots Required)

### Screenshot 1: Home Screen
**What to show**:
- Welcome header with "New Life Church"
- Today's devotion preview card
- Quick access buttons (Events, Prayer, Bible)
- Clean, welcoming interface

**Caption**: "Welcome to New Life Church - Your Daily Spiritual Companion"

---

### Screenshot 2: Daily Devotions
**What to show**:
- List of devotions with dates
- One expanded devotion showing full text
- Scripture reference visible
- "Add Reflection" feature highlighted

**Caption**: "Daily Devotions - Deepen Your Faith with Scripture and Reflection"

---

### Screenshot 3: Bible Search
**What to show**:
- Search bar with example verse (e.g., "John 3:16")
- Search results showing verse text
- Bible version selector (KJV, NIV, ESV, etc.)
- Clean, readable text

**Caption**: "Search Scripture - Multiple Bible Versions at Your Fingertips"

---

### Screenshot 4: Favorite Verses
**What to show**:
- Tab showing "Favorites" selected
- List of 3-4 saved verses
- Heart icons indicating favorites
- Verse references and preview text

**Caption**: "Save Your Favorite Verses - Instant Access Anytime"

---

### Screenshot 5: Events & Service Times
**What to show**:
- Service times clearly displayed (Sunday 9:30 AM, 11:00 AM)
- Upcoming events listed
- Calendar icons
- Location information

**Caption**: "Service Times & Events - Never Miss a Gathering"

---

### Screenshot 6: Prayer Requests
**What to show**:
- Prayer request submission form
- Name, email, and message fields
- Submit button
- Encouraging header text

**Caption**: "Submit Prayer Requests - We Pray With You"

---

### Screenshot 7: About Church
**What to show**:
- Church information section
- Vision and mission statement
- Social media links
- Contact information

**Caption**: "About New Life - Discover Our Vision and Community"

---

### Screenshot 8: Give/Donate (Optional)
**What to show**:
- Giving options (Offering, Tithe, Support, First Fruits)
- PayPal redirect notice
- Scripture verse about giving
- Clean card-based layout

**Caption**: "Give Generously - Support Ministry and Outreach"

---

## ⚠️ Critical Screenshot Rules for App Store

### ✅ DO:
- Show ONLY iOS interface (no Android UI elements)
- Use actual app features (not splash screens)
- Show app in use with real content
- Use correct device dimensions
- Show majority of screenshots with app functionality
- Make sure text is readable

### ❌ DON'T:
- Include device frames (just the app UI)
- Show splash screens only
- Include Apple Watch if not fully supported
- Mix Android and iOS screenshots
- Use marketing materials that don't match app UI
- Show login screens if app doesn't require login

---

## 📤 Uploading to App Store Connect

### Step 1: Log into App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Click **My Apps**
3. Select **New Life Community Church** app
4. Click on version **1.0**

### Step 2: Access Media Manager
1. Scroll to **App Store** tab
2. Find **Previews and Screenshots** section
3. Click **"View All Sizes in Media Manager"**

### Step 3: Delete Old Screenshots
1. Select **iPhone 6.7"** tab
2. Click each screenshot and delete
3. Repeat for **iPhone 6.5"** and **iPad Pro 12.9"**
4. **DELETE all Apple Watch screenshots**

### Step 4: Upload New Screenshots
1. Click the **"+"** button
2. Select your iOS screenshots (PNG or JPG)
3. Upload in the order listed above (Home first, etc.)
4. Drag to reorder if needed

### Step 5: Add Captions (Optional)
- Click each screenshot
- Add the caption text from above
- Helps users understand features

### Step 6: Save and Submit
1. Click **Save** in top-right corner
2. Scroll to **Build** section
3. Verify latest build is selected
4. Click **Submit for Review**

---

## 🧪 Testing the Donation Feature (Bug Fix Verification)

The reviewer reported the donation feature crashed. Here's how to test:

### Test on Web (Currently Running)
1. Navigate to **Give** screen: http://localhost:8080/#/give
2. Click each giving option button:
   - ✅ Offering
   - ✅ Tithe
   - ✅ Support
   - ✅ First Fruits
3. Verify:
   - ✅ Loading message appears: "Opening PayPal in browser..."
   - ✅ Browser opens PayPal donation page
   - ✅ If it fails, error message shows with fallback instructions

### Expected Behavior:
- Button click → Loading snackbar → External browser opens → PayPal page loads
- If fails → Error message with website URL as fallback

### What Was Fixed:
- Added try-catch error handling
- Improved error messages
- Added loading indicators
- Provided fallback instructions (visit website)

---

## 📋 Final Checklist Before Resubmission

- [ ] All screenshots are iOS-only (no Android devices)
- [ ] Removed all Apple Watch screenshots
- [ ] Uploaded 7-8 iPhone screenshots showing app features
- [ ] Uploaded 7-8 iPad screenshots (optional but recommended)
- [ ] No splash screens in screenshots (show actual features)
- [ ] Tested donation feature - PayPal opens correctly
- [ ] Responded to App Review clarifying NO LOGIN REQUIRED
- [ ] Incremented build number in `pubspec.yaml` (e.g., 1.0.0+2)
- [ ] Rebuilt app for release
- [ ] Submitted new build to App Store Connect
- [ ] Clicked "Submit for Review"

---

## 🆘 Need Help?

### Can't Capture iOS Screenshots?
- **Temporary**: Use web screenshots + online mockup generator
- **Permanent**: Borrow a Mac or use cloud Mac service (MacinCloud.com)
- **Alternative**: Hire Fiverr freelancer to capture iOS screenshots ($10-20)

### Screenshots Still Rejected?
- Ensure screenshots show app IN USE (not splash/login)
- Verify dimensions match App Store requirements exactly
- Remove any device frames or mockups
- Show real content (not Lorem Ipsum)

### Donation Feature Still Fails?
- Test PayPal link in browser manually
- Verify hosted_button_id is correct: `V56HCXFE46U5E`
- Check internet connection during test
- Ensure url_launcher package is up to date

---

## 📞 Support Contacts

**Apple App Review**:
- Reply in App Store Connect
- Request phone call (3-5 business days)
- Schedule App Review appointment: https://developer.apple.com/app-store/meet-with-app-review/

**Flutter Community**:
- https://flutter.dev/community
- https://stackoverflow.com/questions/tagged/flutter

---

*Created: February 2, 2026*  
*App: New Life Community Church*  
*Submission ID: a0eda296-9de8-4a8b-af0a-37316f7d37b0*
