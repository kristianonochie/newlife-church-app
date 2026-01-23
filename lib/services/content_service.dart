import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for managing editable page content
class ContentService {
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  // Storage keys for different pages
  static const String _homeContentKey = 'content_home';
  static const String _aboutContentKey = 'content_about';
  static const String _eventsContentKey = 'content_events';
  static const String _contactContentKey = 'content_contact';
  static const String _devotionContentKey = 'content_devotion';
  static const String _bibleContentKey = 'content_bible';
  static const String _prayerContentKey = 'content_prayer';
  static const String _giveContentKey = 'content_give';
  static const String _nlcchatContentKey = 'content_nlcchat';
  static const String _notificationsContentKey = 'content_notifications';
  static const String _watchContentKey = 'content_watch';
  
  /// Get page content by page name
  Future<Map<String, dynamic>> getPageContent(String pageName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKeyForPage(pageName);
    final jsonString = prefs.getString(key);
    
    if (jsonString == null) {
      return _getDefaultContent(pageName);
    }
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding content for $pageName: $e');
      return _getDefaultContent(pageName);
    }
  }
  
  /// Save page content
  Future<bool> savePageContent(String pageName, Map<String, dynamic> content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKeyForPage(pageName);
      final jsonString = jsonEncode(content);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving content for $pageName: $e');
      return false;
    }
  }
  
  /// Reset page content to default
  Future<bool> resetPageContent(String pageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKeyForPage(pageName);
      return await prefs.remove(key);
    } catch (e) {
      print('Error resetting content for $pageName: $e');
      return false;
    }
  }
  
  String _getKeyForPage(String pageName) {
    switch (pageName.toLowerCase()) {
      case 'home':
        return _homeContentKey;
      case 'about':
        return _aboutContentKey;
      case 'events':
        return _eventsContentKey;
      case 'contact':
        return _contactContentKey;
      case 'devotion':
        return _devotionContentKey;
      case 'bible':
        return _bibleContentKey;
      case 'prayer':
        return _prayerContentKey;
      case 'give':
        return _giveContentKey;
      case 'nlcchat':
        return _nlcchatContentKey;
      case 'notifications':
        return _notificationsContentKey;
      case 'watch':
        return _watchContentKey;
      default:
        return 'content_$pageName';
    }
  }
  
  /// Get default content for each page
  Map<String, dynamic> _getDefaultContent(String pageName) {
    switch (pageName.toLowerCase()) {
      case 'home':
        return {
          'welcome_title': 'Welcome to New Life Community Church',
          'welcome_subtitle': 'A place of faith, hope, and love in Tonyrefail',
          'featured_verse': 'For God so loved the world that he gave his one and only Son...',
          'featured_verse_ref': 'John 3:16',
          'hero_image': 'assets/images/hero/church_main.jpg',
          'logo': 'assets/images/icons/church_logo.png',
        };
        
      case 'about':
        return {
          'church_name': 'New Life Community Church',
          'location': 'Tonyrefail, Wales',
          'mission': 'To be a vibrant community of believers who love God, love each other, and serve our community with excellence.',
          'vision': 'To see lives transformed by the power of God\'s love and grace.',
          'pastor_name': 'Helen Owen',
          'founded_year': '2000',
          'description': 'New Life Community Church is a friendly, welcoming church in the heart of Tonyrefail. We believe in the transforming power of Jesus Christ and are committed to helping people grow in their faith.',
          'pastor_image': 'assets/images/pastor_photo.jpg',
          'church_image': 'assets/images/church_building.jpg',
        };
        
      case 'events':
        return {
          'events': [
            {
              'title': 'Sunday Morning Service',
              'time': 'Sunday, 10:30 AM',
              'description': 'Join us for worship, teaching, and fellowship',
              'location': 'Main Sanctuary',
              'recurring': true,
            },
            {
              'title': 'Wednesday Bible Study',
              'time': 'Wednesday, 7:00 PM',
              'description': 'Deep dive into God\'s Word together',
              'location': 'Fellowship Hall',
              'recurring': true,
            },
            {
              'title': 'Youth Night',
              'time': 'Friday, 6:30 PM',
              'description': 'Fun, games, and faith for ages 12-18',
              'location': 'Youth Room',
              'recurring': true,
            },
            {
              'title': 'Prayer Meeting',
              'time': 'Tuesday, 6:00 PM',
              'description': 'Come together in prayer',
              'location': 'Prayer Room',
              'recurring': true,
            },
          ],
        };
        
      case 'contact':
        return {
          'church_name': 'New Life Community Church',
          'address': 'Mill Street Tonyrefail, Porth, Wales. CF39 8AB',
          'phone': '+44 1234 567890',
          'email': 'contact@newlifecc.co.uk',
          'website': 'www.newlifecc.co.uk',
          'office_hours': 'Monday-Friday: 9:00 AM - 5:00 PM',
          'facebook': 'https://facebook.com/newlifecc',
          'instagram': '@newlifecc',
          'twitter': '@newlifecc',
        };
        
      case 'devotion':
        return {
          'page_title': 'Devotion',
          'intro_text': 'Start your day with God\'s Word. Explore daily devotions designed to strengthen your faith and deepen your relationship with Christ.',
          'hero_image': 'assets/images/hero/devotion_hero.jpg',
          'card_background': 'assets/images/devotion_card_bg.jpg',
          'devotion_email': 'devotion@newlifecc.co.uk',
        };
        
      case 'bible':
        return {
          'page_title': 'Bible',
          'intro_text': 'Search and explore God\'s Word. Look up any verse and save your favorites for quick access.',
          'search_placeholder': 'Enter verse reference (e.g., John 3:16)',
          'favorites_title': 'My Favorite Verses',
          'background_image': 'assets/images/hero/bible_background.jpg',
          'bible_email': 'bible@newlifecc.co.uk',
        };
        
      case 'prayer':
        return {
          'page_title': 'Prayer Wall',
          'intro_text': 'Share your prayer requests and pray for others in our community.',
          'submit_button_text': 'Submit Prayer Request',
          'guidelines': 'Please be respectful and specific in your prayer requests. Our community will lift you up in prayer.',
          'prayer_email': 'prayer@newlifecc.co.uk',
          'background_image': 'assets/images/hero/prayer_background.jpg',
        };
        
      case 'give':
        return {
          'page_title': 'Give',
          'intro_text': 'Thank you for your generous support of New Life Community Church.',
          'why_give_title': 'Why Give?',
          'why_give_text': 'Your giving helps us fulfill our mission to spread the Gospel, support our community, and maintain our ministries.',
          'methods_title': 'Ways to Give',
          'bank_details': 'Bank Transfer: Account Number 12345678, Sort Code 12-34-56',
          'hero_image': 'assets/images/hero/giving_hero.jpg',
          'give_email': 'give@newlifecc.co.uk',
        };
        
      case 'nlcchat':
        return {
          'page_title': 'NLC Chat',
          'intro_text': 'Connect with our AI assistant for questions about faith, the Bible, or our church.',
          'welcome_message': 'Hello! I\'m here to help answer questions about New Life Community Church, the Bible, and Christian faith. How can I assist you today?',
          'bot_avatar': 'assets/images/icons/chat_bot_icon.png',
        };
        
      case 'notifications':
        return {
          'page_title': 'Notifications',
          'intro_text': 'Stay updated with church announcements and prayer alerts.',
          'empty_state_text': 'No notifications yet. Check back later for updates!',
          'empty_state_icon': 'assets/images/icons/no_notifications.png',
        };
        
      case 'watch':
        return {
          'page_title': 'TV',
          'intro_text': 'Watch our live services and catch up on past sermons',
          'live_stream_url': 'https://www.youtube.com/@newlifecommunitychurchtony3427/live',
          'youtube_channel_url': 'https://www.youtube.com/@newlifecommunitychurchtony3427',
          'past_videos': '''Sermon 1|https://www.youtube.com/watch?v=11FnPyCbZY8|
Sermon 2|https://www.youtube.com/watch?v=iPCPgLzJdXU|
Sermon 3|https://www.youtube.com/watch?v=9sARTLAV8S8|
Sermon 4|https://www.youtube.com/watch?v=hbzTQRcXGO0|
Sermon 5|https://www.youtube.com/watch?v=nu_dJ7Ihvc4|
Sermon 6|https://www.youtube.com/watch?v=cA-ACV_Y2WA|
Sermon 7|https://www.youtube.com/watch?v=n6JMV7Rl9lk|
Sermon 8|https://www.youtube.com/watch?v=6CTD__uJPS8|
Sermon 9|https://www.youtube.com/watch?v=--Fs5sYHjCw|
Sermon 10|https://www.youtube.com/watch?v=2FAtW7A0GEU|
Sermon 11|https://www.youtube.com/watch?v=zUFEDa7vUu0|''',
          'service_times': 'Sunday Service: 11:00 AM, Tuesday Prayer: 6:00 PM, Wednesday Bible Study: 7:00 PM',
        };
        
      default:
        return {'content': 'Default content for $pageName'};
    }
  }
  
  /// Get list of all editable pages
  List<String> getAllPages() {
    return [
      'Home',
      'About',
      'Events',
      'Contact',
      'Devotion',
      'Bible',
      'Prayer',
      'Give',
      'NLCChat',
      'Notifications',
      'Watch',
    ];
  }
  
  /// Get all content for backup/export
  Future<Map<String, dynamic>> exportAllContent() async {
    final Map<String, dynamic> allContent = {};
    
    for (final page in getAllPages()) {
      allContent[page.toLowerCase()] = await getPageContent(page);
    }
    
    return allContent;
  }
  
  /// Import content from backup
  Future<bool> importAllContent(Map<String, dynamic> content) async {
    try {
      for (final entry in content.entries) {
        await savePageContent(entry.key, entry.value as Map<String, dynamic>);
      }
      return true;
    } catch (e) {
      print('Error importing content: $e');
      return false;
    }
  }
}
