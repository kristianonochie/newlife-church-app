# Visual Design System - New Life Church App

## 🎨 COLOR PALETTE

### Primary Colors
```
Deep Teal (#1B7B7B)
RGB: 27, 123, 123
Used for: Headers, buttons, accents, bottom nav
Psychology: Trust, spirituality, calm faith
```

### Secondary Colors
```
Warm Orange (#E8934A)
RGB: 232, 147, 74
Used for: Highlights, CTAs, special events
Psychology: Warmth, welcome, community spirit
```

### Neutral Colors
```
Light Gray (#F5F5F5) - Backgrounds
Dark Gray (#333333) - Text
White (#FFFFFF) - Cards, surfaces
Light Border (#DDDDDD) - Dividers
```

### Semantic Colors
```
Success Green (#4CAF50) - Saved, completed actions
Error Red (#F44336) - Important warnings, errors
Info Blue (#2196F3) - Information messages
Warning Orange (#FF9800) - Cautions, reminders
```

---

## 📐 LAYOUT GRID

**Breakpoints**:
- Mobile: 360px - 599px
- Tablet: 600px - 899px
- Desktop: 900px+

**Spacing Scale** (in dp - device-independent pixels):
```
8dp - Micro spacing (icons, small gaps)
16dp - Standard padding/margin
24dp - Larger sections, cards
32dp - Major sections
48dp - Top/bottom spacing
```

**Safe Area Margins**:
- Left/Right: 16dp
- Top: 8dp
- Bottom: 8dp (above bottom nav)

---

## 🔤 TYPOGRAPHY

### Font Family
**Primary**: Roboto (Google Font)
- Fallback: System font (Helvetica, San Francisco)

### Type Scale

| Usage | Size | Weight | Line Height |
|-------|------|--------|------------|
| Page Title | 28px | Bold (700) | 1.2 (33.6px) |
| Section Header | 20px | Semi-bold (600) | 1.3 (26px) |
| Card Title | 18px | Semi-bold (600) | 1.4 (25.2px) |
| Body Text | 16px | Regular (400) | 1.5 (24px) |
| Caption | 14px | Regular (400) | 1.4 (19.6px) |
| Button Text | 14px | Semi-bold (600) | 1 (14px) |
| Small Text | 12px | Regular (400) | 1.3 (15.6px) |

### Text Contrast Requirements (WCAG AA)
- Minimum contrast ratio: 4.5:1
- Large text (18px+): 3:1 acceptable

---

## 🎯 COMPONENT SIZES

### Buttons
```
Primary Button:
- Height: 48dp
- Width: Full width (minus 16dp margins)
- Corner radius: 6dp
- Padding: 12dp vertical, 16dp horizontal

Secondary Button:
- Height: 40dp
- Padding: 8dp vertical, 12dp horizontal

Icon Button:
- Size: 48x48dp (touch target)
- Icon: 24x24dp centered
```

### Cards
```
Standard Card:
- Corner radius: 8dp
- Elevation: 2dp (shadow)
- Padding: 16dp
- Margin: 8dp between cards
- Border (optional): 1dp light gray

Featured Card (Devotion):
- Height: 240-280dp
- Padding: 16dp
```

### Input Fields
```
Text Field:
- Height: 48dp
- Corner radius: 4dp
- Border: 1dp, light gray (normal) / teal (focused)
- Padding: 12dp horizontal, 8dp vertical
- Label: 14px, above field
```

### Bottom Navigation
```
Height: 56dp
Icons: 24x24dp
Label: 12px caption
Padding: 8dp between icon and label
Background: White with subtle shadow
Active indicator: Teal background
```

---

## 🖼️ ICON SYSTEM

### Icon Library
**Primary**: Material Design Icons (Google)
- Size standard: 24x24dp
- Size large: 32x32dp
- Size small: 16x16dp
- Color: Inherit text color

### Common Icons Used
```
Home: house
Devotion: book-open
Bible: church
Events: calendar
About: info
Contact: phone
Notifications: bell
Settings: cog
Menu: menu
Back: arrow-left
Search: magnifying-glass
Save: heart (outline/filled)
Share: share-2
Phone: phone
Email: envelope
Location: map-pin
```

---

## 🎨 SCREEN LAYOUTS

### Safe Area (Avoiding Notches/Cutouts)
```
Status Bar: 24-32dp
Content Area: Full width minus 16dp margins
Bottom Navigation: 56dp
Tab Bar (if present): 48dp
```

### Home Screen Layout
```
Status Bar (32dp)
├─ Welcome Banner (60dp) - Teal background
├─ Devotion Card (260dp) - White card with shadow
├─ Action Grid (2x3) (220dp) - 6 quick access buttons
├─ Spacer (16dp)
└─ Bottom Navigation (56dp)
```

### List Screen Layout
```
Status Bar (32dp)
├─ Header/Tabs (48-56dp)
├─ List Items (varying heights) - Each 80-120dp
└─ Bottom Navigation (56dp)
```

### Detail Screen Layout
```
Status Bar (32dp)
├─ Back Button + Title (56dp)
├─ Content (varying)
├─ Actions/Buttons (48dp each)
└─ Bottom Navigation (56dp)
```

---

## 🌈 COMPONENT STYLES

### Primary Button (Call-to-Action)
```
Background: Deep Teal (#1B7B7B)
Text Color: White
Text Weight: Semi-bold (600)
Corner Radius: 6dp
Height: 48dp
Pressed State: Darker teal (#135757)
Disabled: Light gray (#CCCCCC)
Elevation: 2dp
```

### Secondary Button
```
Background: Light Gray (#F5F5F5)
Text Color: Dark Gray (#333333)
Border: 1dp Dark Gray
Corner Radius: 6dp
Height: 40dp
Pressed State: White background
```

### Floating Action Button (if used)
```
Shape: Circle
Size: 56x56dp
Background: Warm Orange (#E8934A)
Icon: 24x24dp White
Elevation: 4dp
Position: Bottom-right, 16dp from edges
```

### Badge/Indicator
```
Background: Error Red (#F44336)
Text: White, 12px semi-bold
Padding: 4dp horizontal
Corner Radius: 8dp
Min width: 20dp
Position: Top-right of icon
```

---

## 📱 RESPONSIVE BREAKPOINTS

### Mobile Layout (360px - 599px)
- Single column content
- Full-width cards and buttons
- Smaller font sizes (14-16px body)
- Bottom navigation always visible
- Hamburger menu for secondary options

### Tablet Layout (600px - 899px)
- 2-column grid for cards
- Larger sidebar (optional)
- Increased padding (20-24px)
- Larger font sizes (16-18px body)
- Side navigation possible

### Desktop Layout (900px+)
- 3+ column grids
- Side navigation drawer
- Horizontal tabs instead of bottom nav
- Maximum content width: 1200px
- Sidebar for filtering/settings

---

## 🎭 Dark Mode Support

### Dark Mode Colors (if implemented)
```
Background: #121212 (Dark gray-black)
Surface: #1E1E1E
Text: #FFFFFF (98% opacity)
Secondary Text: #B3B3B3
Primary Color: #4FA7A7 (Lighter teal for contrast)
Secondary Color: #FFA868 (Lighter orange)
```

---

## ♿ ACCESSIBILITY CHECKLIST

- [x] Minimum touch target: 48x48dp
- [x] Text contrast: 4.5:1 minimum (WCAG AA)
- [x] Readable font size: 16px minimum
- [x] Color not sole indicator of status
- [x] Interactive elements clearly labeled
- [x] Icon + text for important buttons
- [x] Proper heading hierarchy (H1, H2, H3)
- [x] Alt text for images
- [x] Keyboard navigation support
- [x] Screen reader compatible

---

## 📸 SCREENSHOT GUIDELINES

### For Play Store Submission

**Dimensions**:
- Phone: 1080x1920px (9:16 aspect ratio)
- Tablet: 1600x2560px (optional)

**Recommended Screenshots** (5-8 total):
1. **Home Screen** - Show welcome and today's devotion
2. **Devotion Detail** - Display full devotion with reflection
3. **Bible Search** - Show verse search and results
4. **Favorites** - Display saved/favorite verses
5. **Events** - Show service times and events
6. **Contact** - Show prayer request form
7. **About** - Show church information
8. **Notifications** - Show updates and announcements

**Text Overlays** (for Play Store):
- Keep text to 20% of screen
- Use white text with dark shadow for contrast
- Font: Clean, readable (24-32px)
- Highlight key features
- Use arrows to point to features

**Examples**:
```
Screen 1: "Daily Devotions - Grow Your Faith"
Screen 2: "Personal Reflections - Write & Save Locally"
Screen 3: "Bible Search - Multiple Versions Available"
Screen 4: "Save Favorites - Never Lose Inspiration"
Screen 5: "Service Times - Never Miss a Service"
Screen 6: "Prayer Requests - We Pray With You"
Screen 7: "About Us - Know Our Community"
Screen 8: "Stay Connected - Get Updates in Real Time"
```

---

## 🎬 Animation Guidelines

### Transitions
- **Page transitions**: 300ms fade/slide
- **Button press**: 150ms scale down
- **List item**: 200ms fade in
- **Expansion/collapse**: 300ms smooth

### Micro-interactions
- **Save button**: Heart fills (150ms)
- **Notification**: Slide in from top (300ms)
- **Loading**: Spinner (smooth, indefinite)
- **Success**: Checkmark with fade (500ms)

---

## 📐 GRID & ALIGNMENT

### Column Grid
- **Mobile**: 4 columns (16dp gutter)
- **Tablet**: 8 columns (16dp gutter)
- **Desktop**: 12 columns (16dp gutter)

### Baseline Grid
- **4dp baseline grid** for precise alignment
- All elements aligned to 4dp or 8dp increments

### Safe Area Margins
- Respect device notches/safe areas
- iOS: Use Safe Area Insets
- Android: Respect system padding

---

## 🎯 USABILITY PRINCIPLES

1. **Clarity First**: Clear hierarchy, readable text, obvious CTAs
2. **Consistency**: Same components behave the same everywhere
3. **Feedback**: User actions should show immediate feedback
4. **Recovery**: Easy to undo actions or go back
5. **Performance**: Smooth animations, quick load times
6. **Accessibility**: Available to all users, regardless of ability

---

## 📋 DESIGN CHECKLIST FOR EACH SCREEN

- [x] Clear title/header
- [x] Proper spacing (16dp minimum)
- [x] Color contrast WCAG AA
- [x] Touch targets 48dp minimum
- [x] Readable font sizes
- [x] Consistent button styles
- [x] Clear call-to-action
- [x] Proper icon usage
- [x] Mobile responsive
- [x] Accessible to screen readers

---

**Design System Version**: 1.0  
**Last Updated**: January 13, 2026  
**Flutter Implementation**: Material Design 3 (Material 3)
