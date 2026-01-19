# Flutter UI Components Implementation Guide

## Component Library Reference

This file documents the actual Flutter widgets and components used throughout the New Life Church App.

---

## 🎨 MATERIAL 3 DESIGN TOKENS

### Color Implementation (lib/theme/app_theme.dart)

```dart
class AppColors {
  // Primary Colors
  static const Color primaryTeal = Color(0xFF1B7B7B);
  static const Color primaryTealDark = Color(0xFF135757);
  static const Color primaryTealLight = Color(0xFF4FA7A7);
  
  // Secondary Colors
  static const Color secondaryOrange = Color(0xFFE8934A);
  static const Color secondaryOrangeDark = Color(0xFFD47A2A);
  static const Color secondaryOrangeLight = Color(0xFFFFA868);
  
  // Neutral Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color borderLight = Color(0xFFDDDDDD);
  
  // Semantic Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color warningOrange = Color(0xFFFF9800);
}
```

---

## 🔘 BUTTON COMPONENTS

### Primary Button (Full Width CTA)

```dart
Widget buildPrimaryButton({
  required String label,
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 2,
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  );
}
```

### Secondary Button

```dart
Widget buildSecondaryButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 40,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.textDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    ),
  );
}
```

### Icon Button (Touch Target 48x48)

```dart
Widget buildIconButton({
  required IconData icon,
  required VoidCallback onPressed,
  Color color = AppColors.primaryTeal,
  double size = 24,
}) {
  return SizedBox(
    width: 48,
    height: 48,
    child: IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
    ),
  );
}
```

---

## 📇 CARD COMPONENTS

### Standard Card with Padding

```dart
Widget buildStandardCard({
  required Widget child,
  VoidCallback? onTap,
  EdgeInsets padding = const EdgeInsets.all(16),
  Color backgroundColor = AppColors.surfaceWhite,
}) {
  return Card(
    color: backgroundColor,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: padding,
        child: child,
      ),
    ),
  );
}
```

### Featured Devotion Card

```dart
Widget buildDevotionCard({
  required String title,
  required String author,
  required String preview,
  required VoidCallback onTap,
  required VoidCallback onFavorite,
  bool isFavorited = false,
}) {
  return buildStandardCard(
    onTap: onTap,
    padding: const EdgeInsets.fromLTRBP(16, 16, 16, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By $author',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: AppColors.secondaryOrange,
              ),
              onPressed: onFavorite,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          preview,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
```

---

## 📝 INPUT COMPONENTS

### Text Field with Label

```dart
Widget buildTextField({
  required String label,
  required TextEditingController controller,
  required String? Function(String?) validator,
  TextInputType keyboardType = TextInputType.text,
  int minLines = 1,
  int maxLines = 1,
  String? hintText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: AppColors.backgroundLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: AppColors.primaryTeal,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    ],
  );
}
```

### Search Field

```dart
Widget buildSearchField({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
  String placeholder = 'Search verses, chapters...',
}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: placeholder,
      prefixIcon: const Icon(Icons.search, color: AppColors.primaryTeal),
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            )
          : null,
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
  );
}
```

---

## 🗂️ LIST COMPONENTS

### List Item Tile

```dart
Widget buildListTile({
  required String title,
  required String subtitle,
  IconData? leading,
  IconData? trailing = Icons.chevron_right,
  VoidCallback? onTap,
  Color? tintColor,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    leading: leading != null
        ? Icon(leading, color: tintColor ?? AppColors.primaryTeal)
        : null,
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),
    trailing: trailing != null
        ? Icon(trailing, color: AppColors.textSecondary)
        : null,
    onTap: onTap,
  );
}
```

### Expandable List Item

```dart
Widget buildExpansionTile({
  required String title,
  required String subtitle,
  required Widget expandedContent,
  bool initiallyExpanded = false,
}) {
  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      initiallyExpanded: initiallyExpanded,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: expandedContent,
        ),
      ],
    ),
  );
}
```

---

## 🧭 NAVIGATION COMPONENTS

### Bottom Navigation Bar

```dart
Widget buildBottomNavigation({
  required int currentIndex,
  required IndexedWidgetBuilder onItemTapped,
}) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onItemTapped,
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.surfaceWhite,
    selectedItemColor: AppColors.primaryTeal,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 4,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.book_open),
        label: 'Devotion',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.church),
        label: 'Bible',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Events',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.info),
        label: 'About',
      ),
    ],
  );
}
```

### App Bar with Back Button

```dart
PreferredSizeWidget buildAppBar({
  required String title,
  bool showBackButton = true,
  List<Widget>? actions,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    backgroundColor: AppColors.primaryTeal,
    elevation: 2,
    centerTitle: true,
    leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          )
        : null,
    actions: actions,
  );
}
```

---

## ⚡ LOADING & STATE COMPONENTS

### Loading Indicator

```dart
Widget buildLoadingIndicator({
  String? message = 'Loading...',
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    ),
  );
}
```

### Error State

```dart
Widget buildErrorState({
  required String message,
  required VoidCallback onRetry,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: AppColors.errorRed,
        ),
        const SizedBox(height: 16),
        Text(
          'Oops!',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        buildPrimaryButton(
          label: 'Try Again',
          onPressed: onRetry,
        ),
      ],
    ),
  );
}
```

### Empty State

```dart
Widget buildEmptyState({
  required IconData icon,
  required String title,
  required String message,
  VoidCallback? onAction,
  String? actionLabel,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 64,
          color: AppColors.primaryTeal,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 24),
          buildPrimaryButton(
            label: actionLabel,
            onPressed: onAction,
          ),
        ],
      ],
    ),
  );
}
```

---

## 📐 SPACING & PADDING HELPERS

### Standard Padding Values

```dart
class AppSpacing {
  // Micro
  static const double xs = 8.0;
  
  // Small
  static const double sm = 12.0;
  
  // Standard
  static const double md = 16.0;
  
  // Large
  static const double lg = 20.0;
  
  // Extra Large
  static const double xl = 24.0;
  
  // XXL
  static const double xxl = 32.0;
}

// Usage
Padding(
  padding: const EdgeInsets.all(AppSpacing.md),
  child: child,
)
```

---

## 🎯 RESPONSIVE LAYOUT HELPERS

### Breakpoint Detection

```dart
class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }
}

// Usage
if (ResponsiveUtils.isMobile(context)) {
  // Single column layout
} else {
  // Multi-column layout
}
```

### Responsive Grid Builder

```dart
Widget buildResponsiveGrid({
  required BuildContext context,
  required List<Widget> children,
}) {
  final isMobile = ResponsiveUtils.isMobile(context);
  final crossAxisCount = isMobile ? 2 : 3;
  
  return GridView.count(
    crossAxisCount: crossAxisCount,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    padding: const EdgeInsets.all(16),
    children: children,
  );
}
```

---

## 📋 FORM VALIDATION HELPER

```dart
class FormValidator {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value!)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value?.isEmpty ?? true) {
      return '$fieldName is required';
    }
    return null;
  }
}
```

---

## 🔔 NOTIFICATION COMPONENTS

### Snackbar Helper

```dart
void showSuccessSnackbar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.successGreen,
      duration: duration,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {},
      ),
    ),
  );
}
```

### Dialog Helper

```dart
Future<void> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
```

---

**Component Library Version**: 1.0  
**Last Updated**: January 13, 2026  
**Framework**: Flutter 3.38.5 with Material Design 3
