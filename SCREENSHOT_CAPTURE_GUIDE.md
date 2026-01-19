# Play Store Screenshot Capture Guide

## 📸 HOW TO CAPTURE SCREENSHOTS FOR GOOGLE PLAY STORE

### Setup Requirements
- Device/Emulator running Android
- Screenshot app or ADB
- Image editing tool (Photoshop, GIMP, Figma, or online editor)

---

## 📱 TECHNICAL SPECIFICATIONS

### Image Requirements
| Property | Specification |
|----------|---------------|
| Format | PNG or JPG |
| Dimensions | 1080 x 1920 px (9:16 aspect ratio) |
| File Size | < 100MB |
| Min Screenshots | 2 |
| Max Screenshots | 8 |
| Recommended | 5-6 for best results |

### Device Type Support
- Phone (required) - Use Pixel 6/7 dimensions
- Tablet (optional) - 1600 x 2560 px
- Screenshot shows only first device type to users

---

## 🎯 SCREENSHOT SEQUENCE (Recommended Order)

### Screenshot #1: Home Screen (Hook)
**Purpose**: First impression, attention-grabber
**What to show**:
- Full welcome banner with "New Life Church" logo
- Daily devotion preview card visible
- Quick action buttons below
- Clean, inviting appearance

**Text Overlay**:
```
"Welcome to New Life Church"
(in white text, top 30% of screen)

"Your Daily Spiritual Companion"
(in white text with shadow, center)
```

**Positioning**:
- Place text at 20% opacity with drop shadow
- Use 32-48px font for visibility
- Center text on screen

---

### Screenshot #2: Daily Devotions
**Purpose**: Show content depth and personal features
**What to show**:
- Devotion list with 2-3 expandable items
- One expanded showing full devotion text
- Reflection text field visible
- Heart icon (favorite button)

**Text Overlay**:
```
"Daily Devotions"
(top center)

"Deepen Your Faith With Reflections"
(middle-center)
```

**Positioning**:
- Show expanded devotion card with content visible
- Heart icon should be clearly clickable
- Reflection text area should be filled with sample text

---

### Screenshot #3: Bible Search
**Purpose**: Show powerful search and study features
**What to show**:
- Search field with entered text (e.g., "John 3:16")
- Verse result displayed clearly
- Bible version selector dropdown visible
- Multiple results list below

**Text Overlay**:
```
"Search Scripture"
(top center)

"Multiple Bible Versions • Save Favorites"
(below search bar)
```

**Positioning**:
- Show search in use with results visible
- Highlight different Bible versions available
- Show verse text clearly readable

---

### Screenshot #4: Favorite Verses
**Purpose**: Show personalization and offline capability
**What to show**:
- List of saved favorite verses
- Each with reference and preview text
- Highlight feature at top: "Your Saved Verses"

**Text Overlay**:
```
"Your Favorite Verses"
(top center)

"Instant Access • Always Available"
(subtitle)
```

**Positioning**:
- Show 3-4 favorited verses
- Each clearly marked with heart icon
- Make sure text is readable and well-spaced

---

### Screenshot #5: Service Times & Events
**Purpose**: Show community connection
**What to show**:
- Service times displayed prominently (Sunday 9:30 AM, 11:00 AM)
- Special events listed below (e.g., "Prayer Meeting Wed 7pm")
- Calendar icon and time clearly visible

**Text Overlay**:
```
"Service Times & Events"
(top center)

"Never Miss a Gathering"
(subtitle)
```

**Positioning**:
- Lead with main service times
- Show 2-3 upcoming events
- Make time display very clear and prominent

---

### Screenshot #6: Prayer Requests
**Purpose**: Show community care and involvement features
**What to show**:
- Prayer request form filled out
- Subject line visible (e.g., "Health for my mother")
- Request text area with sample text
- Submit button ready to tap

**Text Overlay**:
```
"Prayer Requests"
(top center)

"We Pray With You & Your Family"
(subtitle)
```

**Positioning**:
- Show form with sample text to demonstrate
- Make submit button prominent and accessible
- Show confidentiality note if visible on screen

---

### Screenshot #7: About Church (Optional)
**Purpose**: Show community and leadership
**What to show**:
- Church mission/vision visible
- Contact information
- Leadership team section beginning to show
- Social links or website reference

**Text Overlay**:
```
"Know Your Church"
(top center)

"Our Vision, Mission & Leadership"
(subtitle)
```

**Positioning**:
- Highlight key church information
- Show beautiful design and readability
- Include church address and website mention

---

### Screenshot #8: Notifications
**Purpose**: Show engagement and connection features
**What to show**:
- Notification list with real items
- Mix of announcement types (events, devotions, reminders)
- Timestamps visible
- Badge count if applicable

**Text Overlay**:
```
"Stay Connected"
(top center)

"Real-time Updates & Announcements"
(subtitle)
```

**Positioning**:
- Show diverse notification types
- Include timestamps for credibility
- Demonstrate recency of communications

---

## 🎨 TEXT OVERLAY GUIDELINES

### Font & Style
- **Font**: Bold, clean (Arial, Roboto, Helvetica)
- **Size**: 32-48px minimum for readability
- **Color**: White (#FFFFFF)
- **Shadow**: Dark shadow for contrast
  - Shadow offset: 2px down, 2px right
  - Shadow blur: 4px
  - Shadow color: Black with 50% opacity

### Positioning
- **Primary headline**: 15-20% from top
- **Secondary text**: 35-45% from top
- **Coverage**: Keep text to 20-30% of screen
- **Margins**: 16-24px from edges
- **Line spacing**: 8-12px between lines

### Shadow Implementation
```
Text color: #FFFFFF
Shadow: 2px 2px 4px rgba(0, 0, 0, 0.5)
OR use outline for better contrast:
Text color: #FFFFFF with #000000 2-3px outline
```

### Examples in Context
```
Screenshot 1 (Home):
"Welcome to New Life Church" (40px bold)
"Your Daily Spiritual Companion" (32px)
Positioned at 25% and 45% from top

Screenshot 3 (Bible):
"Search Scripture" (40px bold)
"Multiple Versions • Save Favorites" (28px)
Positioned near search field
```

---

## 📷 ACTUAL SCREENSHOT PROCESS

### Using ADB (Android Debug Bridge)
```bash
# Connect device or start emulator
adb devices  # verify connection

# Take screenshot and save to computer
adb shell screencap /sdcard/screenshot1.png
adb pull /sdcard/screenshot1.png ./screenshot1.png

# Clean up
adb shell rm /sdcard/screenshot1.png
```

### Using Android Studio Emulator
1. Open Emulator
2. Run app (`flutter run`)
3. Press Ctrl+S or click screenshot icon
4. Screenshots auto-save to `~/Android/Emulator/Screenshots/`

### Using Physical Device
1. Enable USB Debugging
2. Connect device
3. Use ADB commands above
OR
4. Use device's native screenshot (Power + Volume Down)
5. Transfer via USB/cloud

---

## ✏️ EDITING SCREENSHOTS

### Using GIMP (Free)
1. Open screenshot in GIMP
2. Select Text Tool (T)
3. Click position for text
4. Choose Arial/Roboto, size 40-48px, white color
5. Add drop shadow: Filters > Light and Shadow > Drop Shadow
6. Export as PNG

### Using Photoshop
1. Open image
2. Type Tool (T)
3. Enter text, set to white, Arial bold, 40-48px
4. Effects > Drop Shadow (2px, 2px, 4px blur, 50% opacity)
5. File > Export As > PNG

### Using Online Tools (Free)
- **Pixlr**: pixlr.com (has text and shadow tools)
- **Figma**: figma.com (professional design tool, free tier)
- **Canva**: canva.com (templates for screenshots)

### Recommended Online Tool: Canva
1. Go to canva.com
2. Search "App Screenshot" template
3. Upload your screenshot image
4. Add text with shadow and styling
5. Download as PNG

---

## 🖼️ EDITING CHECKLIST

- [ ] Screenshot properly sized (1080x1920px)
- [ ] Text overlay clear and readable
- [ ] White text with dark shadow for contrast
- [ ] No blurry or out-of-focus areas
- [ ] App UI clearly visible
- [ ] No personal information visible
- [ ] Features prominently displayed
- [ ] Consistent styling across all 5-8 screenshots
- [ ] File format: PNG
- [ ] File size: < 100MB

---

## 🎭 VISUAL CONSISTENCY ACROSS SCREENSHOTS

### Color Scheme for Overlays
Use consistent branding:
- **Text**: White (#FFFFFF)
- **Shadow**: Black with 50% opacity
- **Accent color**: Optional Teal (#1B7B7B) for highlights

### Typography Consistency
- **All headlines**: Same font, weight, size
- **All subheadlines**: Consistent size and spacing
- **All body text**: Same color and shadow treatment

### Layout Pattern
Every screenshot should have:
1. **Headline** (40px bold) - 20% from top
2. **Subheadline** (28px) - 40% from top
3. **Feature area**: Bottom 60% of screen
4. **Margins**: 16-24px from edges

---

## 🚀 DEPLOYMENT SEQUENCE

### Before Uploading to Play Store

1. **Capture all screenshots**
   - Use emulator or device
   - Take 5-8 screenshots

2. **Resize if needed**
   - Target: 1080 x 1920px
   - Use free tool: pixlr.com or photopea.com

3. **Add text overlays**
   - Use Canva, Photoshop, or GIMP
   - Apply drop shadows
   - Verify readability

4. **Quality check**
   - Zoom to 100% and verify text clarity
   - Check shadow depth
   - Ensure no typos
   - Verify color contrast (min 4.5:1)

5. **Name files**
   ```
   screenshot_01_home.png
   screenshot_02_devotions.png
   screenshot_03_bible.png
   screenshot_04_favorites.png
   screenshot_05_events.png
   screenshot_06_prayer.png
   screenshot_07_about.png
   screenshot_08_notifications.png
   ```

6. **Upload to Play Store**
   - Go to Play Console
   - App > Screenshots (Mobile)
   - Upload in order (1-8)
   - Verify display on store listing
   - Save and publish

---

## 📋 SCREENSHOT CONTENT VERIFICATION

| Screenshot | Feature Visible | Text Visible | Layout Clear | Professional |
|-----------|-----------------|--------------|--------------|--------------|
| #1 Home | Welcome, Devotion | Headline ✓ | Yes | Yes |
| #2 Devotions | List, Expansion | Title, Subtitle | Yes | Yes |
| #3 Bible | Search, Results | Search visible | Yes | Yes |
| #4 Favorites | Saved verses | "Your Verses" | Yes | Yes |
| #5 Events | Times, List | Headline visible | Yes | Yes |
| #6 Prayer | Form, Fields | "Prayer Requests" | Yes | Yes |
| #7 About | Info, Contact | "About Church" | Yes | Yes |
| #8 Notifications | List, Timestamp | Headlines visible | Yes | Yes |

---

## 🎯 FINAL PLAYSTORE SUBMISSION

### Screenshots Ready Checklist
- [x] 5-8 screenshots captured
- [x] Each 1080 x 1920px
- [x] PNG format, < 100MB each
- [x] Text overlays added
- [x] White text with shadows
- [x] High contrast (4.5:1 minimum)
- [x] No personal information
- [x] Named sequentially
- [x] All features represented
- [x] Professional appearance

### Upload Sequence
1. Log in to Google Play Console
2. Select app: New Life Church
3. Go to: Releases > Production
4. Edit Release
5. Scroll to: Screenshots (Mobile)
6. Upload all 5-8 images in order
7. Verify preview
8. Save changes
9. Review & publish

---

**Screenshot Guide Version**: 1.0  
**Last Updated**: January 13, 2026  
**Recommended Tool**: Canva or Photoshop  
**Total Time Required**: 30-45 minutes for all screenshots
