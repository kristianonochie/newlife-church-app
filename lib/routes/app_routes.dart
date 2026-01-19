import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/devotion/devotion_screen.dart';
import '../screens/devotion/devotion_detail_screen.dart';
import '../screens/bible/bible_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/nlcchat/nlcchat_screen.dart';
import '../screens/prayer/prayer_screen.dart';
import '../screens/give/give_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/watch/watch_screen.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: '/devotion',
        name: 'devotion',
        builder: (context, state) => const DevotionScreen(),
      ),
      GoRoute(
        path: '/devotion/:id',
        name: 'devotion-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DevotionDetailScreen(devotionId: id);
        },
      ),
      GoRoute(
        path: '/bible',
        name: 'bible',
        builder: (context, state) => const BibleScreen(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/nlcchat',
        name: 'nlcchat',
        builder: (context, state) => const NLCChatScreen(),
      ),
      GoRoute(
        path: '/prayer',
        name: 'prayer',
        builder: (context, state) => const PrayerScreen(),
      ),
      GoRoute(
        path: '/give',
        name: 'give',
        builder: (context, state) => const GiveScreen(),
      ),
      GoRoute(
        path: '/watch',
        name: 'watch',
        builder: (context, state) => const WatchScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}
