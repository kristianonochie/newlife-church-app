import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../services/notification_service.dart';
import '../services/devotion_service.dart';
import '../services/bible_service.dart';
import '../providers/devotion_provider.dart';
import '../providers/bible_provider.dart';
import '../providers/notification_provider.dart';

class AppProviders {
  static final List<SingleChildWidget> providers = [
    // Services
    if (!kIsWeb)
      Provider<NotificationService>(
        create: (_) => NotificationService(),
      ),
    Provider<DevotionService>(
      create: (_) => DevotionService(),
    ),
    Provider<BibleService>(
      create: (_) => BibleService(),
    ),
    
    // State Providers
    ChangeNotifierProvider<DevotionProvider>(
      create: (context) => DevotionProvider(
        context.read<DevotionService>(),
      ),
    ),
    ChangeNotifierProvider<BibleProvider>(
      create: (context) => BibleProvider(
        bibleService: context.read<BibleService>(),
      ),
    ),
    if (!kIsWeb)
      ChangeNotifierProvider<NotificationProvider>(
        create: (context) => NotificationProvider(
          context.read<NotificationService>(),
        ),
      ),
  ];
}
