import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

/// Service for admin authentication and notification management
class AdminService {
  static const String _adminKey = 'is_admin_logged_in';
  static const String _currentUsernameKey = 'current_admin_username';
  static const String _currentRoleKey = 'current_admin_role';
  static const String _adminUsersKey = 'admin_users';

  // Default credentials
  static const String _defaultAdminUsername = 'nlccapp';
  static const String _defaultAdminPassword = 'Nlccapp@2026';
  static const String _superAdminUsername = 'superadmin';
  static const String _superAdminPassword = 'SuperAdmin@2026!';
  
  final Dio _dio = Dio();
  
  // Firebase Cloud Messaging Server Key (replace with your actual key from Firebase Console)
  // Get from: Firebase Console > Project Settings > Cloud Messaging > Server Key
  final String _fcmServerKey = 'YOUR_FCM_SERVER_KEY_HERE';
  
  /// Check if user is logged in as admin
  Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adminKey) ?? false;
  }

  /// Return current admin profile (username, role, priority, restrictions)
  Future<Map<String, dynamic>?> getCurrentAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_currentUsernameKey);
    if (username == null) return null;
    final users = await _loadUsers();
    return users.firstWhere(
      (u) => u['username'] == username,
      orElse: () => {},
    );
  }

  Future<bool> isSuperAdmin() async {
    final current = await getCurrentAdmin();
    return current != null && current['role'] == 'superadmin';
  }

  /// Ensure default admin and superadmin accounts exist
  Future<void> _ensureDefaultUsers() async {
    final users = await _loadUsers();
    final hasSuper = users.any((u) => u['username'] == _superAdminUsername);
    final hasAdmin = users.any((u) => u['username'] == _defaultAdminUsername);

    if (!hasSuper) {
      users.add({
        'username': _superAdminUsername,
        'password': _superAdminPassword,
        'role': 'superadmin',
        'priority': 10,
        'restrictions': <String>[],
      });
    }

    if (!hasAdmin) {
      users.add({
        'username': _defaultAdminUsername,
        'password': _defaultAdminPassword,
        'role': 'admin',
        'priority': 5,
        'restrictions': <String>[],
      });
    }

    await _saveUsers(users);
  }

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_adminUsersKey) ?? [];
    final users = raw
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .toList();
    return users;
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = users.map((u) => jsonEncode(u)).toList().cast<String>();
    await prefs.setStringList(_adminUsersKey, raw);
  }
  
  /// Login with username and password (supports superadmin + staff admins)
  Future<bool> login(String username, String password) async {
    await _ensureDefaultUsers();
    final users = await _loadUsers();
    final match = users.firstWhere(
      (u) => u['username'] == username && u['password'] == password,
      orElse: () => {},
    );

    if (match.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adminKey, true);
    await prefs.setString(_currentUsernameKey, match['username']);
    await prefs.setString(_currentRoleKey, match['role']);
    return true;
  }
  
  /// Logout admin user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adminKey);
    await prefs.remove(_currentUsernameKey);
    await prefs.remove(_currentRoleKey);
  }

  /// Create a new admin user (only superadmin can create)
  Future<bool> createAdminUser({
    required String username,
    required String password,
    String role = 'admin',
    int priority = 1,
    List<String> restrictions = const [],
  }) async {
    if (!await isSuperAdmin()) return false;

    final users = await _loadUsers();
    final exists = users.any((u) => u['username'] == username);
    if (exists) return false;

    users.add({
      'username': username,
      'password': password,
      'role': role,
      'priority': priority,
      'restrictions': restrictions,
    });

    await _saveUsers(users);
    return true;
  }

  /// List all admins (superadmin only)
  Future<List<Map<String, dynamic>>> listAdmins() async {
    if (!await isSuperAdmin()) return [];
    return _loadUsers();
  }

  /// Update admin user (superadmin only)
  Future<bool> updateAdminUser({
    required String username,
    String? newPassword,
    String? role,
    int? priority,
    List<String>? restrictions,
  }) async {
    if (!await isSuperAdmin()) return false;

    final users = await _loadUsers();
    final index = users.indexWhere((u) => u['username'] == username);
    if (index == -1) return false;

    // Prevent editing superadmin account (except by itself if needed)
    if (users[index]['role'] == 'superadmin') return false;

    if (newPassword != null) users[index]['password'] = newPassword;
    if (role != null) users[index]['role'] = role;
    if (priority != null) users[index]['priority'] = priority;
    if (restrictions != null) users[index]['restrictions'] = restrictions;

    await _saveUsers(users);
    return true;
  }

  /// Delete admin user (superadmin only)
  Future<bool> deleteAdminUser(String username) async {
    if (!await isSuperAdmin()) return false;

    final users = await _loadUsers();
    final user = users.firstWhere(
      (u) => u['username'] == username,
      orElse: () => {},
    );

    // Cannot delete superadmin or self
    if (user.isEmpty || user['role'] == 'superadmin') return false;

    users.removeWhere((u) => u['username'] == username);
    await _saveUsers(users);
    return true;
  }

  /// Check if current user has permission to perform action
  Future<bool> hasPermission(String action) async {
    final current = await getCurrentAdmin();
    if (current == null) return false;

    // Superadmin has all permissions
    if (current['role'] == 'superadmin') return true;

    // Check if action is in restrictions list
    final restrictions = List<String>.from(current['restrictions'] ?? []);
    return !restrictions.contains(action);
  }

  /// Get available permission types
  static List<Map<String, String>> getAvailablePermissions() {
    return [
      {'key': 'edit_home', 'label': 'Edit Home Page'},
      {'key': 'edit_about', 'label': 'Edit About Page'},
      {'key': 'edit_events', 'label': 'Edit Events Page'},
      {'key': 'edit_contact', 'label': 'Edit Contact Page'},
      {'key': 'edit_devotion', 'label': 'Edit Devotion Page'},
      {'key': 'edit_bible', 'label': 'Edit Bible Page'},
      {'key': 'edit_prayer', 'label': 'Edit Prayer Page'},
      {'key': 'edit_give', 'label': 'Edit Give Page'},
      {'key': 'edit_nlcchat', 'label': 'Edit NLCChat Page'},
      {'key': 'edit_notifications', 'label': 'Edit Notifications Page'},
      {'key': 'edit_watch', 'label': 'Edit Watch Page'},
      {'key': 'send_notifications', 'label': 'Send Push Notifications'},
      {'key': 'view_analytics', 'label': 'View Analytics'},
      {'key': 'manage_users', 'label': 'Manage Users (Superadmin Only)'},
    ];
  }
  
  /// Send notification to all app users via FCM
  /// Uses the 'all_users' topic that all app users subscribe to
  Future<bool> sendNotificationToAll({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(
        'https://fcm.googleapis.com/fcm/send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$_fcmServerKey',
          },
        ),
        data: {
          'to': '/topics/all_users',
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'badge': '1',
          },
          'data': data ?? {},
          'priority': 'high',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
  
  /// Send notification to specific topic
  Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(
        'https://fcm.googleapis.com/fcm/send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$_fcmServerKey',
          },
        ),
        data: {
          'to': '/topics/$topic',
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'badge': '1',
          },
          'data': data ?? {},
          'priority': 'high',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending notification to topic: $e');
      return false;
    }
  }
}
