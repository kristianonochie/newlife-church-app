/// Web stub for NotificationService (Firebase Messaging not available on web)
library;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  List<Map<String, dynamic>> _notifications = [];

  Future<void> init() async {
    // Web stub: no Firebase Messaging available
    // Load notification history from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    try {
      final decoded = jsonDecode(notificationsJson) as List<dynamic>;
      _notifications = decoded
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      _notifications = [];
    }
  }

  Future<void> addNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data ?? {},
      'isRead': false,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _notifications.insert(0, notification);
    await _saveNotifications();
  }

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      await _saveNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    await _saveNotifications();
  }

  Future<void> deleteNotification(int id) async {
    _notifications.removeWhere((n) => n['id'] == id);
    await _saveNotifications();
  }

  Future<void> clearNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  int getUnreadCount() {
    return _notifications.where((n) => n['isRead'] == false).length;
  }

  List<Map<String, dynamic>> getNotifications() => _notifications;

  int getNotificationCount() => _notifications.length;

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', jsonEncode(_notifications));
  }

  String getFormattedTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return dateTime.toString().split(' ')[0];
      }
    } catch (e) {
      return timestamp;
    }
  }
}
