import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/devotion_provider.dart';
import 'providers/bible_provider.dart';
import 'providers/notification_provider.dart';
import 'services/devotion_service.dart';
import 'services/bible_service.dart';
import 'services/notification_service.dart';
import 'services/chat_service.dart';
import 'services/analytics_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize analytics
  await AnalyticsService().init();
  
  runApp(const NewLifeChurchApp());
}

class NewLifeChurchApp extends StatelessWidget {
  const NewLifeChurchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => DevotionService()),
        Provider(create: (_) => BibleService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        // Notification service requires late initialization due to Firebase
        // Providers that depend on services
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
        // NotificationProvider with nullable Firebase support
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            NotificationService(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'New Life Community Church',
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
