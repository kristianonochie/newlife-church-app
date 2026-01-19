import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;
  
  // Dummy factory for testing without Firebase

  NotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;

  List<Map<String, dynamic>> _notifications = [];

  Future<void> init() async {
    try {
      // Try to initialize Firebase
      _firebaseMessaging = FirebaseMessaging.instance;
    } catch (e) {
      // Firebase not initialized - skip push notifications
      print('Firebase not available: $e');
      _firebaseMessaging = null;
    }
    
    // Initialize local notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    _localNotifications = FlutterLocalNotificationsPlugin();
    await _localNotifications.initialize(initSettings);

    // Request permissions only if Firebase is available
    if (_firebaseMessaging != null) {
      await _firebaseMessaging!.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleMessage);

      // Background handler must be a top-level function
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      // Get FCM token
      String? token = await _firebaseMessaging!.getToken();
      await _saveFCMToken(token ?? '');
      
      // Subscribe to topics for receiving notifications
      await _subscribeToTopics();
    }

    // Load persisted notifications
    await _loadNotifications();
  }
  
  /// Subscribe to all notification topics
  Future<void> _subscribeToTopics() async {
    if (_firebaseMessaging == null) return;
    
    try {
      // Subscribe to all_users topic (for admin broadcast)
      await _firebaseMessaging!.subscribeToTopic('all_users');
      
      // Subscribe to other topics
      await _firebaseMessaging!.subscribeToTopic('announcements');
      await _firebaseMessaging!.subscribeToTopic('devotions');
      await _firebaseMessaging!.subscribeToTopic('events');
      await _firebaseMessaging!.subscribeToTopic('prayer');
      
      print('Subscribed to notification topics');
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }
}

// Background handler - top-level
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  final service = NotificationService();
  await service.addNotification(
    title: message.notification?.title ?? 'New Message',
    body: message.notification?.body ?? '',
  );
}

extension NotificationServiceImpl on NotificationService {
  Future<void> _handleMessage(RemoteMessage message) async {
    await addNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
    );

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'New Life Community Church',
      channelDescription: 'Church notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> addNotification({
    required String title,
    required String body,
  }) async {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };

    _notifications.insert(0, notification);
    await _saveNotifications();
  }

  Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications');

    if (notificationsJson != null) {
      try {
        final decoded = jsonDecode(notificationsJson) as List<dynamic>;
        _notifications = decoded
            .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _notifications = [];
      }
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', jsonEncode(_notifications));
  }

  List<Map<String, dynamic>> getNotifications() => _notifications;

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['read'] = true;
      await _saveNotifications();
    }
  }

  int getUnreadCount() {
    return _notifications.where((n) => n['read'] == false).length;
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
  }
}
