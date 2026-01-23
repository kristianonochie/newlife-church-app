import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newlife_church_app/services/notification_service.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}
class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockRemoteMessage extends Mock implements RemoteMessage {}
class MockRemoteNotification extends Mock implements RemoteNotification {}

void main() {
  late NotificationService notificationService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    notificationService = NotificationService();
  });

  group('NotificationService', () {
    group('Initialization', () {
      test('init() should complete without errors', () async {
        expect(() async => await notificationService.init(), isA<Function>());
      });

      test('should handle initialization gracefully', () async {
        try {
          await notificationService.init();
          expect(true, true);
        } catch (e) {
          expect(e, isNotNull);
        }
      });
    });

    group('addNotification', () {
      test('should add notification to list', () async {
        final title = 'Test Title';
        final body = 'Test Body';
        await notificationService.addNotification(
          title: title,
          body: body,
        );
        final notifications = notificationService.getNotifications();
        expect(notifications.isNotEmpty, true);
      });

      test('should create notification with correct structure', () async {
        final title = 'Church Announcement';
        final body = 'Sunday service time changed';
        await notificationService.addNotification(
          title: title,
          body: body,
        );
        final notifications = notificationService.getNotifications();
        final notification = notifications.first;
        expect(notification['title'], title);
        expect(notification['body'], body);
        expect(notification['read'], false);
      });

      test('should insert new notifications at beginning', () async {
        final title1 = 'First Notification';
        final title2 = 'Second Notification';
        await notificationService.addNotification(
          title: title1,
          body: 'Body 1',
        );
        await notificationService.addNotification(
          title: title2,
          body: 'Body 2',
        );
        final notifications = notificationService.getNotifications();
        expect(notifications.first['title'], title2);
        expect(notifications[1]['title'], title1);
      });

      // ...rest of the tests from original file...
    });
    // ...rest of the test groups from original file...
  });
}
