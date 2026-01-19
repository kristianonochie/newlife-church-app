# Admin Features Guide

## Overview
The New Life Church app now includes comprehensive admin capabilities with full content management and granular user permissions.

## Superadmin Access
**Credentials:**
- Username: `superadmin`
- Password: `SuperAdmin@2026!`

## Key Features

### 1. Full Page Content Editing (10 Pages)
The superadmin can edit text content on **all 10 app pages**:

1. **Home** - Welcome text, featured verse
2. **About** - Church info, mission, vision, pastor details
3. **Events** - Service times, recurring events
4. **Contact** - Address, phone, email, social media links
5. **Devotion** - Page title, intro text
6. **Bible** - Search placeholder, favorites title
7. **Prayer** - Intro text, submission button text, guidelines
8. **Give** - Giving methods, bank details, intro text
9. **NLCChat** - Welcome message, intro text
10. **Notifications** - Page title, empty state text

**How to edit:**
1. Login as superadmin
2. Navigate to Admin Dashboard → **Edit Content** tab
3. Select page from dropdown
4. Edit text fields
5. Click "Save Changes"

### 2. User Management System

#### User Roles
- **Superadmin** - Full access to everything including user management
- **Admin** - Standard admin access
- **Editor** - Content editing only
- **Viewer** - Read-only access

#### Priority Levels
- Range: 1-10 (10 = highest priority)
- Used for resolving permission conflicts

#### Granular Permissions (Restrictions)
Superadmin can **deny** specific permissions to users:

**Page Editing Permissions:**
- Edit Home Page
- Edit About Page
- Edit Events Page
- Edit Contact Page
- Edit Devotion Page
- Edit Bible Page
- Edit Prayer Page
- Edit Give Page
- Edit NLCChat Page
- Edit Notifications Page

**System Permissions:**
- Send Push Notifications
- View Analytics
- Manage Users (Superadmin only)

**How restrictions work:**
- By default, users have **full access** to all features
- Check a permission to **DENY** access to that feature
- Superadmin always has all permissions (cannot be restricted)

### 3. Creating New Users

**Steps:**
1. Login as superadmin
2. Go to Admin Dashboard → **Manage Users** tab
3. Fill out the form:
   - Username (minimum 3 characters)
   - Password (minimum 6 characters)
   - Role (Admin/Editor/Viewer)
   - Priority Level (1-10)
   - Restrictions (check boxes to deny access)
4. Click "Create User"

**Example Use Cases:**

**Content Editor (can only edit pages, no notifications):**
- Role: Editor
- Priority: 3
- Restrictions: ✓ Send Push Notifications, ✓ View Analytics, ✓ Manage Users

**Events Manager (can only edit Events page and send notifications):**
- Role: Editor
- Priority: 2
- Restrictions: ✓ Edit Home, ✓ Edit About, ✓ Edit Contact, ✓ Edit Devotion, ✓ Edit Bible, ✓ Edit Prayer, ✓ Edit Give, ✓ Edit NLCChat, ✓ View Analytics, ✓ Manage Users

**Analytics Viewer (can only view analytics, no editing):**
- Role: Viewer
- Priority: 1
- Restrictions: All editing permissions and Send Notifications

### 4. Managing Existing Users

From the **Manage Users** tab, you can:

- **View all users** - See username, role, priority, restrictions
- **Edit user** - Click edit icon to modify role, priority, or restrictions
- **Delete user** - Click delete icon (requires confirmation)
- **Protected users** - Superadmin accounts cannot be edited or deleted

### 5. Admin Dashboard Tabs

The dashboard has **4 tabs**:

1. **Analytics** - App usage statistics, session counts, feature usage
2. **Notifications** - Send push notifications to all users or specific topics
3. **Edit Content** - Edit text content for all 10 pages
4. **Manage Users** - Create, edit, delete admin users (superadmin only)

## Security Notes

1. **Only superadmin can:**
   - Create new users
   - Edit user permissions
   - Delete users
   - Access the Manage Users tab

2. **Default admin account:**
   - Username: `nlccapp`
   - Password: `Nlccapp@2026`
   - Cannot access user management

3. **Passwords** are stored locally (SharedPreferences)
   - For production, migrate to Firebase Authentication or secure backend

4. **Restrictions are enforced** at the service level
   - Even if a user navigates to restricted pages, service methods check permissions

## Best Practices

1. **Create specific-role users** instead of giving everyone full admin access
2. **Use meaningful usernames** (e.g., `editor_john`, `events_manager`)
3. **Set appropriate priorities** for permission conflict resolution
4. **Regularly review user list** and remove inactive accounts
5. **Change default passwords** immediately in production

## Future Enhancements

Consider implementing:
- Password reset functionality
- User activity logging
- Email notifications for user creation/deletion
- Two-factor authentication
- Cloud-based user storage (Firebase Auth)
- Session expiration/timeout
- IP-based access restrictions

---

**Last Updated:** January 14, 2026
