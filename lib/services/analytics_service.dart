import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for tracking app analytics and usage statistics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Local storage keys
  static const String _sessionIdKey = 'session_id';
  static const String _installDateKey = 'install_date';
  static const String _totalSessionsKey = 'total_sessions';
  
  String? _currentSessionId;
  
  /// Initialize analytics and track app session
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Track installation date
    if (!prefs.containsKey(_installDateKey)) {
      await prefs.setString(_installDateKey, DateTime.now().toIso8601String());
      await trackEvent('app_installed', {});
    }
    
    // Increment session count
    final sessions = prefs.getInt(_totalSessionsKey) ?? 0;
    await prefs.setInt(_totalSessionsKey, sessions + 1);
    
    // Generate session ID
    _currentSessionId = '${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_sessionIdKey, _currentSessionId!);
    
    // Track session start
    await trackEvent('session_start', {
      'session_number': sessions + 1,
    });
    
    // Track device info
    await _trackDeviceInfo();
  }
  
  /// Track feature usage
  Future<void> trackFeatureUsage(String feature, {Map<String, dynamic>? params}) async {
    await trackEvent('feature_used', {
      'feature_name': feature,
      ...?params,
    });
    
    // Increment local feature counter
    final prefs = await SharedPreferences.getInstance();
    final key = 'feature_count_$feature';
    final count = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, count + 1);
  }
  
  /// Track screen views
  Future<void> trackScreenView(String screenName) async {
    await trackEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Track custom events
  Future<void> trackEvent(String eventName, Map<String, dynamic> params) async {
    try {
      final data = {
        'event_name': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _currentSessionId,
        'params': params,
      };
      
      // Store locally
      await _storeEventLocally(data);
      
      // Send to server (optional - requires backend setup)
      // await _sendToServer(data);
    } catch (e) {
      print('Error tracking event: $e');
    }
  }
  
  /// Get local analytics data
  Future<Map<String, dynamic>> getLocalAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'total_sessions': prefs.getInt(_totalSessionsKey) ?? 0,
      'install_date': prefs.getString(_installDateKey),
      'feature_usage': await _getFeatureUsageCounts(),
      'stored_events': await _getStoredEvents(),
    };
  }
  
  /// Get feature usage statistics
  Future<Map<String, int>> _getFeatureUsageCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final features = [
      'home',
      'devotion',
      'bible',
      'bible_search',
      'bible_favorite',
      'events',
      'about',
      'prayer',
      'prayer_submit',
      'give',
      'give_offering',
      'give_tithe',
      'give_support',
      'give_firstfruits',
      'nlcchat',
      'nlcchat_message',
      'notifications',
      'contact',
    ];
    
    final Map<String, int> usage = {};
    for (final feature in features) {
      final key = 'feature_count_$feature';
      usage[feature] = prefs.getInt(key) ?? 0;
    }
    
    return usage;
  }
  
  /// Store event locally for analytics
  Future<void> _storeEventLocally(Map<String, dynamic> event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = prefs.getStringList('analytics_events') ?? [];
    
    // Keep only last 100 events to avoid storage issues
    if (events.length >= 100) {
      events.removeAt(0);
    }
    
    events.add(jsonEncode(event));
    await prefs.setStringList('analytics_events', events);
  }
  
  /// Get stored events
  Future<List<Map<String, dynamic>>> _getStoredEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final events = prefs.getStringList('analytics_events') ?? [];
    
    return events.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
  
  /// Track device information
  Future<void> _trackDeviceInfo() async {
    // In a real app, you'd get actual device info using device_info_plus package
    await trackEvent('device_info', {
      'platform': 'web', // or 'android', 'ios'
      'app_version': '1.0.0',
    });
  }
  
  /// Get aggregated statistics (for admin dashboard)
  Future<Map<String, dynamic>> getAggregatedStats() async {
    final local = await getLocalAnalytics();
    final featureUsage = local['feature_usage'] as Map<String, int>;
    
    // Calculate top features
    final sortedFeatures = featureUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topFeatures = sortedFeatures.take(5).map((e) => {
      'name': e.key,
      'count': e.value,
    }).toList();
    
    return {
      'total_sessions': local['total_sessions'],
      'install_date': local['install_date'],
      'days_since_install': _calculateDaysSinceInstall(local['install_date']),
      'top_features': topFeatures,
      'total_events': (local['stored_events'] as List).length,
      'feature_breakdown': featureUsage,
    };
  }
  
  int _calculateDaysSinceInstall(String? installDate) {
    if (installDate == null) return 0;
    final install = DateTime.parse(installDate);
    return DateTime.now().difference(install).inDays;
  }
  
  /// Get estimated download count (requires backend with global counter)
  /// This is a placeholder - actual implementation needs server-side tracking
  Future<int> getDownloadCount() async {
    // In production, query your backend API
    // Example: GET https://yourapi.com/app/download-count
    
    // For now, return local session count as approximation
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalSessionsKey) ?? 0;
  }
  
  /// Track active users (requires real-time database)
  /// This is a placeholder - actual implementation needs Firebase Realtime Database
  Future<void> trackActiveUser() async {
    try {
      // In production, update Firebase Realtime Database with:
      // - User's session ID
      // - Last active timestamp
      // - Auto-expire after 5 minutes of inactivity
      
      print('Active user tracked: $_currentSessionId');
    } catch (e) {
      print('Error tracking active user: $e');
    }
  }
}
