import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  NotificationProvider(this._notificationService) {
    _init();
  }

  Future<void> _init() async {
    await _notificationService.init();
    _loadNotifications();
  }

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void _loadNotifications() {
    _notifications = _notificationService.getNotifications();
    _unreadCount = _notificationService.getUnreadCount();
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String body,
  }) async {
    await _notificationService.addNotification(title: title, body: body);
    _loadNotifications();
  }

  Future<void> markAsRead(int id) async {
    await _notificationService.markAsRead(id);
    _loadNotifications();
  }

  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      if (notification['read'] == false) {
        await _notificationService.markAsRead(notification['id'] as int);
      }
    }
    _loadNotifications();
  }

  Future<void> clearAll() async {
    await _notificationService.clearAll();
    _loadNotifications();
  }

  void refresh() {
    _loadNotifications();
  }
}
