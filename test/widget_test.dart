// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:newlife_church_app/main.dart';
import 'package:provider/provider.dart';
import 'package:newlife_church_app/providers/notification_provider.dart';
import 'package:newlife_church_app/services/notification_service.dart';
import 'package:mockito/mockito.dart';

class TestNotificationProvider extends NotificationProvider {
  TestNotificationProvider()
      : super(NotificationService(firebaseMessaging: null, localNotifications: null));
  @override
  List<Map<String, dynamic>> get notifications => [];
  @override
  int get unreadCount => 0;
}
void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TestNotificationProvider(),
          ),
        ],
        child: const NewLifeChurchApp(),
      ),
    );
    // Verify that the app builds and shows the home screen title
    expect(find.textContaining('New Life'), findsWidgets);
  });
}
