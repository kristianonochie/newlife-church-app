import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../data/devotions_2026_complete.dart';

class Devotion {
  final String id;
  final String title;
  final String scripture;
  final String body;
  final DateTime date;
  final String author;
  final String? story;
  final String? thoughts;
  final String? action;
  final String? confession;
  final String? reflection;

  Devotion({
    required this.id,
    required this.title,
    required this.scripture,
    required this.body,
    required this.date,
    required this.author,
    this.story,
    this.thoughts,
    this.action,
    this.confession,
    this.reflection,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'scripture': scripture,
    'body': body,
    'date': date.toIso8601String(),
    'author': author,
    'story': story,
    'thoughts': thoughts,
    'action': action,
    'confession': confession,
    'reflection': reflection,
  };

  factory Devotion.fromJson(Map<String, dynamic> json) => Devotion(
    id: json['id'] as String,
    title: json['title'] as String,
    scripture: json['scripture'] as String,
    body: json['body'] as String,
    date: DateTime.parse(json['date'] as String),
    author: json['author'] as String,
    story: json['story'] as String?,
    thoughts: json['thoughts'] as String?,
    action: json['action'] as String?,
    confession: json['confession'] as String?,
    reflection: json['reflection'] as String?,
  );
}

class DevotionService {
  static final DevotionService _instance = DevotionService._internal();
  
  factory DevotionService() {
    return _instance;
  }
  
  DevotionService._internal();

  List<Devotion> _devotions = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _loadDevotion();
    _initialized = true;
  }

  Future<void> _loadDevotion() async {
    final prefs = await SharedPreferences.getInstance();
    final devotionVersion = prefs.getInt('devotion_version') ?? 0;
    final currentVersion = 3; // Increment this when devotion structure or source changes
    
    // Force regenerate if version changed or devotions don't exist
    if (devotionVersion < currentVersion) {
      await _createSampleDevotions();
      await prefs.setInt('devotion_version', currentVersion);
      return;
    }
    
    final devotionsJson = prefs.getString('devotions');
    
    if (devotionsJson != null) {
      try {
        final decoded = jsonDecode(devotionsJson) as List<dynamic>;
        _devotions = decoded
            .map((e) => Devotion.fromJson(Map<String, dynamic>.from(e as Map<String, dynamic>)))
            .toList();
      } catch (e) {
        _devotions = [];
      }
    }
    
    // If no devotions exist or we don't have enough, create sample data
    if (_devotions.isEmpty || _devotions.length < 365) {
      await _createSampleDevotions();
    }
  }

  Future<void> _createSampleDevotions() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    // Map curated devotions by date for fast lookup
    final curatedByDate = {for (final d in devotions2026) d['date']!: d};

    _devotions = [];
    for (int i = 0; i < 365; i++) {
      final devotionDate = startOfYear.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(devotionDate);
      final data = curatedByDate[dateKey];

      if (data != null) {
        _devotions.add(Devotion(
          id: dateKey,
          title: data['title']!,
          scripture: data['scripture']!,
          body: data['body']!,
          date: devotionDate,
          author: data['author'] ?? 'New Life Community Church',
          story: data['story'],
          thoughts: data['thoughts'],
          action: data['action'],
          confession: data['confession'],
        ));
      } else {
        // Fallback generated devotion to ensure 365 coverage
        _devotions.add(Devotion(
          id: dateKey,
          title: 'Daily Trust - Day ${i + 1}',
          scripture: 'Psalm 23:1',
          body: 'The Lord is my shepherd; I lack nothing.',
          date: devotionDate,
          author: 'New Life Community Church',
          story: 'On $dateKey, remember that God shepherds you through every valley and over every hill.',
          thoughts: 'Where do you need to trust His shepherding today?',
          action: 'Write one burden you will hand to God and pray over it.',
          confession: 'Lord, You are my shepherd; I trust You with this day. Amen.',
        ));
      }
    }

    await _saveDevotion();
  }

  Future<void> _saveDevotion() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_devotions.map((d) => d.toJson()).toList());
    await prefs.setString('devotions', json);
  }

  Devotion? getTodaysDevotion() {
    final today = DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd').format(today);
    
    try {
      return _devotions.firstWhere(
        (d) => DateFormat('yyyy-MM-dd').format(d.date) == dateString,
      );
    } catch (e) {
      // If no devotion for today, return the latest
      return _devotions.isNotEmpty ? _devotions.first : null;
    }
  }

  List<Devotion> getAllDevotions() => _devotions;

  Devotion? getDevotionById(String id) {
    try {
      return _devotions.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addDevotion(Devotion devotion) async {
    _devotions.insert(0, devotion);
    await _saveDevotion();
  }

  Future<void> addUserReflection(String devotionId, String reflection) async {
    final index = _devotions.indexWhere((d) => d.id == devotionId);
    if (index != -1) {
      final devotion = _devotions[index];
      _devotions[index] = Devotion(
        id: devotion.id,
        title: devotion.title,
        scripture: devotion.scripture,
        body: devotion.body,
        date: devotion.date,
        author: devotion.author,
        reflection: reflection,
      );
      await _saveDevotion();
    }
  }
}
