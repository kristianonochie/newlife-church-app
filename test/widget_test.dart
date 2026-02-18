// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newlife_church_app/providers/devotion_provider.dart';
import 'package:newlife_church_app/providers/bible_provider.dart';
import 'package:newlife_church_app/providers/notification_provider.dart';
import 'package:newlife_church_app/services/devotion_service.dart';
import 'package:newlife_church_app/services/bible_service.dart';
import 'package:newlife_church_app/services/notification_service.dart';
import 'package:newlife_church_app/services/chat_service.dart';
import 'package:newlife_church_app/routes/app_routes.dart';
import 'package:newlife_church_app/theme/app_theme.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {
  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool providesAppNotificationSettings = true,
    bool sound = true,
  }) async {
    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.notDetermined,
      alert: AppleNotificationSetting.notSupported,
      announcement: AppleNotificationSetting.notSupported,
      badge: AppleNotificationSetting.notSupported,
      carPlay: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.notSupported,
      notificationCenter: AppleNotificationSetting.notSupported,
      providesAppNotificationSettings: AppleNotificationSetting.notSupported,
      showPreviews: AppleShowPreviewSetting.notSupported,
      sound: AppleNotificationSetting.notSupported,
      timeSensitive: AppleNotificationSetting.notSupported,
    );
  }

  @override
  Future<String?> getToken({String? vapidKey}) async {
    return 'mock-fcm-token';
  }

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}
}
class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds smoke test', (WidgetTester tester) async {
    // Create mock Firebase and local notifications
    final mockFirebaseMessaging = MockFirebaseMessaging();
    final mockLocalNotifications = MockFlutterLocalNotificationsPlugin();
    
    // Create mock services - these don't require Firebase
    final devotionService = DevotionService();
    final bibleService = BibleService();
    final chatService = ChatService();
    
    // Create notification service with mocked Firebase and local notifications
    final notificationService = NotificationService(
      firebaseMessaging: mockFirebaseMessaging,
      localNotifications: mockLocalNotifications,
    );
    
    // Initialize services
    await devotionService.init();
    await bibleService.init();
    await notificationService.init();
    
    // Build our app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider(create: (_) => devotionService),
          Provider(create: (_) => bibleService),
          ChangeNotifierProvider(create: (_) => chatService),
          ChangeNotifierProvider(
            create: (context) => DevotionProvider(
              context.read<DevotionService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => BibleProvider(
              bibleService: context.read<BibleService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => NotificationProvider(
              notificationService,
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'New Life Church',
          theme: AppTheme.lightTheme,
          routerConfig: AppRoutes.router,
        ),
      ),
    );
    
    // Allow widgets to initialize
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // Verify that the app builds successfully (basic smoke test)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
