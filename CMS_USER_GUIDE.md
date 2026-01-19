# Content Management System (CMS) - Complete Guide

## Overview

Your New Life Church app now has a **built-in Content Editor** where anyone can edit all page content without writing code. This makes the app fully standalone and editable by church staff.

---

## Accessing the Content Editor

### Steps:
1. **Open App** → Click drawer menu (☰)
2. **Click "Admin"**
3. **Login** with credentials:
   - Username: `nlccapp`
   - Password: `Nlccapp@2026`
4. **Click "Edit Content" tab** (third tab)

---

## What You Can Edit

### 1. **Home Page** 
Customize your homepage welcome message:
- Welcome Title
- Welcome Subtitle
- Featured Bible Verse
- Verse Reference

### 2. **About Page**
Update church information:
- Church Name
- Location
- Mission Statement
- Vision Statement
- Pastor Name
- Founded Year
- Church Description

### 3. **Events Page** ⭐ FULLY DYNAMIC
Manage all church events:
- Add unlimited events
- Edit existing events
- Delete events
- Each event has:
  - **Title** (e.g., "Sunday Morning Service")
  - **Time** (e.g., "Sunday, 10:30 AM")
  - **Description** (What happens at the event)
  - **Location** (e.g., "Main Sanctuary")

### 4. **Contact Page**
Update contact information:
- Church Name
- Physical Address
- Phone Number
- Email Address
- Website URL
- Office Hours
- Social Media Links (Facebook, Instagram, Twitter)

---

## How to Edit Content

### Standard Pages (Home, About, Contact):

1. **Select the page** you want to edit (click the chip at top)
2. **Edit the text fields** - type directly in the boxes
3. **Click "Save Changes"** button (top right)
4. **Confirmation message** appears: "✓ Content saved successfully!"
5. **Changes are INSTANT** - view the page to see updates

### Events Page (Special):

#### **Adding a New Event:**
1. Click **"Add Event"** button (top right)
2. Fill in event details:
   - **Event Title**: Name of the event
   - **Time**: When it happens
   - **Description**: Brief description
   - **Location**: Where it takes place
3. Click **"Save Changes"**

#### **Editing an Event:**
1. Find the event card
2. Change any field you want
3. Click **"Save Changes"**

#### **Deleting an Event:**
1. Find the event card
2. Click the **red trash icon** (🗑️) in the top right
3. Event is removed immediately
4. Click **"Save Changes"**

#### **Reordering Events:**
- Events appear in the order you add them
- To reorder: Delete and re-add in desired order

---

## Example: Adding a New Event

### Scenario: Youth Night on Fridays

1. Go to Admin Dashboard → Edit Content → Events
2. Click **"Add Event"**
3. Fill in:
   ```
   Event Title: Youth Night
   Time: Friday, 7:00 PM
   Description: Fun, games, worship, and fellowship for ages 12-18
   Location: Youth Center
   ```
4. Click **"Save Changes"**
5. Done! Event now appears in the Events page

---

## Reset to Default

If you make a mistake or want to start over:

1. Click **"Reset"** button (top right, next to Save)
2. Confirm the action
3. Page content returns to original default
4. Your custom changes are lost (be careful!)

---

## Content Storage

### Where is content saved?
- **Locally on the device** using SharedPreferences
- Each device has its own content
- Changes made on one device don't affect others

### For Global Content (All Devices):
Set up Firebase Realtime Database or Firestore:
1. Store content in Firebase instead of SharedPreferences
2. All devices fetch content from Firebase
3. Changes made by admin sync to all users
4. See "Upgrading to Cloud Storage" section below

---

## Features & Benefits

### ✅ What This Enables:

1. **No Coding Required**
   - Church secretary can update events
   - Pastor can edit about page
   - Anyone with admin access can manage content

2. **Real-Time Updates**
   - Changes save instantly
   - No app redeployment needed
   - No developer involvement required

3. **Unlimited Events**
   - Add as many events as you want
   - Change anytime
   - Delete old events easily

4. **Flexible Content**
   - Edit text, descriptions, times, locations
   - Customize for special occasions
   - Update contact info when it changes

5. **Fully Standalone**
   - App works without backend server
   - No monthly hosting costs
   - Complete control over content

---

## Best Practices

### 1. **Keep Content Current**
- Update events weekly
- Remove past events
- Check contact info monthly

### 2. **Use Clear Descriptions**
- Be specific about times and locations
- Include age groups if relevant
- Mention special requirements

### 3. **Test After Changes**
- Save changes
- Navigate to the page
- Verify content displays correctly

### 4. **Backup Important Content**
- Take screenshots of your events
- Write down custom text before resetting
- Keep a Word doc with contact info

---

## Troubleshooting

### "Changes not appearing"
**Solution:**
1. Make sure you clicked **"Save Changes"**
2. Close and reopen the page
3. Fully restart the app
4. Check if you're editing the correct page

### "Event deleted by accident"
**Solution:**
1. If you haven't saved yet: Close without saving
2. If saved: Manually re-add the event
3. Prevention: Take notes before deleting

### "Content looks wrong"
**Solution:**
1. Click **"Reset"** to restore defaults
2. Start editing fresh
3. Save changes carefully

### "Can't access admin panel"
**Solution:**
1. Verify login credentials
2. Check drawer menu for "Admin" item
3. Ensure app is up to date

---

## Upgrading to Cloud Storage

### Current Setup (Local Storage):
- ✅ Works offline
- ✅ No server costs
- ✅ Simple and reliable
- ❌ Each device has separate content
- ❌ Admin must update each device

### Cloud Setup (Firebase):

#### Benefits:
- ✅ One update = all devices sync
- ✅ Content always up to date
- ✅ Backup in the cloud
- ✅ Access from anywhere

#### Setup Steps:

1. **Enable Firebase Realtime Database**
   ```bash
   flutter pub add firebase_database
   ```

2. **Update ContentService**
   Replace SharedPreferences with Firebase:
   ```dart
   import 'package:firebase_database/firebase_database.dart';
   
   final database = FirebaseDatabase.instance.ref();
   
   // Save content
   await database.child('pages/events').set(content);
   
   // Load content
   final snapshot = await database.child('pages/events').get();
   final content = snapshot.value;
   ```

3. **Configure Firebase Rules**
   ```json
   {
     "rules": {
       "pages": {
         ".read": true,
         ".write": "auth != null"
       }
     }
   }
   ```

4. **Test**
   - Edit content on one device
   - Open app on another device
   - Verify changes appear automatically

---

## Advanced Features (Future)

### Suggested Enhancements:

1. **Image Upload**
   - Add event photos
   - Upload church logo
   - Add pastor photo

2. **Rich Text Editor**
   - Bold, italics, colors
   - Bullet points
   - Hyperlinks

3. **Content Scheduling**
   - Schedule events to auto-publish
   - Set expiration dates
   - Recurring events (weekly, monthly)

4. **Multi-Language Support**
   - Welsh and English versions
   - Toggle between languages
   - Translate all content

5. **Version History**
   - Undo changes
   - View edit history
   - Restore previous versions

6. **User Roles**
   - Admin: Full access
   - Editor: Edit content only
   - Viewer: Read-only access

---

## Security Considerations

### Current Security:
- Admin password required
- Content stored locally (can't be hacked remotely)
- Simple and secure for church use

### Production Recommendations:
1. **Change default password** in `admin_service.dart`
2. **Use Firebase Authentication** for multi-user access
3. **Enable audit logging** to track who edited what
4. **Backup content regularly** (export/import feature)

---

## Content Fields Reference

### Home Page Fields:
| Field | Purpose | Example |
|-------|---------|---------|
| welcome_title | Main headline | "Welcome to New Life Church" |
| welcome_subtitle | Tagline | "A place of faith and fellowship" |
| featured_verse | Bible verse text | "For God so loved the world..." |
| featured_verse_ref | Verse reference | "John 3:16" |

### About Page Fields:
| Field | Purpose | Example |
|-------|---------|---------|
| church_name | Official name | "New Life Community Church" |
| location | City/area | "Tonyrefail, Wales" |
| mission | Mission statement | "To spread God's love..." |
| vision | Vision statement | "A thriving community..." |
| pastor_name | Lead pastor | "Pastor John Smith" |
| founded_year | Year established | "2000" |
| description | Long description | "We are a Bible-believing..." |

### Events Page Fields:
| Field | Purpose | Example |
|-------|---------|---------|
| title | Event name | "Sunday Morning Service" |
| time | When it happens | "Sunday, 10:30 AM" |
| description | What happens | "Worship and teaching" |
| location | Where it happens | "Main Sanctuary" |

### Contact Page Fields:
| Field | Purpose | Example |
|-------|---------|---------|
| church_name | Official name | "New Life Community Church" |
| address | Physical address | "123 Church St, CF39 8AA" |
| phone | Phone number | "+44 1234 567890" |
| email | Email address | "nlccapp@newlifecc.co.uk" |
| website | Website URL | "www.newlifecc.co.uk" |
| office_hours | When office is open | "Mon-Fri: 9 AM - 5 PM" |
| facebook | Facebook link | "facebook.com/newlifecc" |
| instagram | Instagram handle | "@newlifecc" |
| twitter | Twitter handle | "@newlifecc" |

---

## Training Checklist

### For Church Staff:

- [ ] Know admin login credentials
- [ ] Practice adding an event
- [ ] Practice editing existing event
- [ ] Practice deleting an event
- [ ] Know how to save changes
- [ ] Know how to reset if needed
- [ ] Understand what each field does
- [ ] Test changes on live app
- [ ] Know who to contact for help

---

## Support & Help

- **Technical Issues**: nlccapp@newlifecc.co.uk
- **Content Questions**: Ask your church admin
- **Feature Requests**: Contact NLCC Tech Team
- **Documentation**: This guide + ADMIN_ANALYTICS_GUIDE.md

---

## Summary

You now have a **complete, standalone church app** with:
- ✅ Fully editable content (no coding required)
- ✅ Admin panel with content editor
- ✅ Dynamic events page
- ✅ Customizable Home, About, Contact pages
- ✅ Analytics tracking
- ✅ Push notifications
- ✅ All church features (Bible, Prayer, Give, Chat)

**Anyone with admin access can manage all content!**

---

**Last Updated:** January 14, 2026
**Version:** 1.0.0
**Feature:** Content Management System (CMS)
