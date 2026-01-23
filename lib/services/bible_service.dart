import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:html/parser.dart' as html_parser;

enum BibleVersion {
  kjv('King James Version', 'KJV'),
  niv('New International Version', 'NIV'),
  nlt('New Living Translation', 'NLT'),
  amplified('Amplified Bible', 'AMP'),
  gnb('Good News Bible', 'GNB'),
  esv('English Standard Version', 'ESV');

  final String fullName;
  final String abbreviation;

  const BibleVersion(this.fullName, this.abbreviation);
}

class BibleVerse {
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final BibleVersion version;

  BibleVerse({
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.version = BibleVersion.kjv,
  });

  Map<String, dynamic> toJson() => {
        'bookName': bookName,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'version': version.abbreviation,
      };

  factory BibleVerse.fromJson(Map<String, dynamic> json) => BibleVerse(
        bookName: json['bookName'] as String? ?? 'Unknown',
        chapter: json['chapter'] as int? ?? 0,
        verse: json['verse'] as int? ?? 0,
        text: json['text'] as String? ?? '',
        version: _parseVersion(json['version'] as String? ?? 'KJV'),
      );

  static BibleVersion _parseVersion(String abbr) {
    return BibleVersion.values.firstWhere(
      (v) => v.abbreviation == abbr,
      orElse: () => BibleVersion.kjv,
    );
  }

  String get reference => '$bookName $chapter:$verse';
  String get referenceWithVersion => '$reference (${version.abbreviation})';
}

class BibleService {
  static final BibleService _instance = BibleService._internal();

  factory BibleService() {
    return _instance;
  }

  BibleService._internal();

  final Dio _dio = Dio();
  final List<BibleVerse> _favorites = [];
  bool _initialized = false;
  Map<String, Map<BibleVersion, BibleVerse>> _localBibleCache = {};
  BibleVersion _selectedVersion = BibleVersion.kjv;

  BibleVersion get selectedVersion => _selectedVersion;

  void setSelectedVersion(BibleVersion version) {
    _selectedVersion = version;
  }

  List<BibleVersion> get availableVersions => BibleVersion.values.toList();

  Future<void> init() async {
    if (_initialized) return;
    await _loadBibleDataJson();
    await _loadFavorites();
    await _loadSelectedVersion();
    _initialized = true;
  }

  Future<void> _loadBibleDataJson() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/bible_data.json');
      final Map<String, dynamic> data = json.decode(jsonStr);
      _localBibleCache = {};
      data.forEach((book, chapters) {
        (chapters as Map<String, dynamic>).forEach((chapter, verses) {
          (verses as Map<String, dynamic>).forEach((verse, text) {
            _addVerse(_localBibleCache, book, int.parse(chapter),
                int.parse(verse), text);
          });
        });
      });
    } catch (e) {
      // Fallback to demo data if loading fails
      _initializeLocalBibleCache();
    }
  }

  Future<void> _loadSelectedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final versionAbbr = prefs.getString('selected_bible_version') ?? 'KJV';
    _selectedVersion = BibleVersion.values.firstWhere(
      (v) => v.abbreviation == versionAbbr,
      orElse: () => BibleVersion.kjv,
    );
  }

  void _initializeLocalBibleCache() {
    _localBibleCache = _buildCompleteBibleDatabase();
  }

  Map<String, Map<BibleVersion, BibleVerse>> _buildCompleteBibleDatabase() {
    final cache = <String, Map<BibleVersion, BibleVerse>>{};

    // Add representative verses from all 66 books
    _addVerse(cache, 'Genesis', 1, 1,
        'In the beginning God created the heavens and the earth.');
    _addVerse(cache, 'Exodus', 20, 1,
        'And God spoke all these words, saying, I am the Lord thy God.');
    _addVerse(
        cache, 'Leviticus', 19, 18, 'Thou shalt love thy neighbor as thyself.');
    _addVerse(cache, 'Numbers', 6, 24, 'The Lord bless thee, and keep thee.');
    _addVerse(cache, 'Deuteronomy', 6, 4,
        'Hear, O Israel: The Lord our God is one Lord.');
    _addVerse(cache, 'Joshua', 1, 8,
        'This book of the law shall not depart out of thy mouth.');
    _addVerse(cache, 'Judges', 6, 12,
        'The Lord is with thee, thou mighty man of valour.');
    _addVerse(cache, 'Ruth', 3, 11, 'Thou art a woman of excellence.');
    _addVerse(cache, '1 Samuel', 15, 22, 'To obey is better than sacrifice.');
    _addVerse(cache, '2 Samuel', 7, 12,
        'Thy seed shall be established before me for ever.');
    _addVerse(cache, '1 Kings', 3, 9,
        'Give therefore thy servant an understanding heart.');
    _addVerse(cache, '2 Kings', 5, 10, 'Go and wash in Jordan seven times.');
    _addVerse(
        cache, '1 Chronicles', 16, 9, 'Sing unto him, sing psalms unto him.');
    _addVerse(cache, '2 Chronicles', 7, 14, 'If my people humble themselves.');
    _addVerse(cache, 'Ezra', 7, 10,
        'Ezra had prepared his heart to seek the law of the Lord.');
    _addVerse(
        cache, 'Nehemiah', 8, 10, 'The joy of the Lord is your strength.');
    _addVerse(cache, 'Job', 42, 5,
        'I have heard of thee by the hearing of the ear: but now mine eye seeth thee.');
    _addVerse(
        cache, 'Psalm', 23, 1, 'The Lord is my shepherd; I shall not want.');
    _addVerse(
        cache, 'Proverbs', 3, 5, 'Trust in the Lord with all thine heart.');
    _addVerse(
        cache, 'Ecclesiastes', 12, 13, 'Fear God, and keep his commandments.');
    _addVerse(cache, 'Song of Solomon', 2, 4,
        'He brought me to the banqueting house, and his banner over me was love.');
    _addVerse(cache, 'Isaiah', 40, 31,
        'But they that wait upon the Lord shall renew their strength.');
    _addVerse(cache, 'Jeremiah', 29, 11,
        'For I know the thoughts that I think toward you, saith the Lord.');
    _addVerse(cache, 'Lamentations', 3, 22,
        'It is of the Lord\'s mercies that we are not consumed.');
    _addVerse(cache, 'Ezekiel', 37, 3, 'Son of man, can these bones live?');
    _addVerse(cache, 'Daniel', 6, 10,
        'When Daniel knew that the writing was signed.');
    _addVerse(cache, 'Hosea', 6, 6, 'For I desired mercy, and not sacrifice.');
    _addVerse(cache, 'Joel', 2, 28,
        'And it shall come to pass afterward, that I will pour out my spirit upon all flesh.');
    _addVerse(cache, 'Amos', 5, 24,
        'But let judgment run down as waters, and righteousness as a mighty stream.');
    _addVerse(
        cache, 'Obadiah', 1, 3, 'The pride of thine heart hath deceived thee.');
    _addVerse(cache, 'Jonah', 2, 2,
        'I cried by reason of mine affliction unto the Lord.');
    _addVerse(
        cache, 'Micah', 6, 8, 'He hath shewed thee, O man, what is good.');
    _addVerse(cache, 'Nahum', 1, 7,
        'The Lord is good, a strong hold in the day of trouble.');
    _addVerse(cache, 'Habakkuk', 2, 4, 'the just shall live by his faith.');
    _addVerse(cache, 'Zephaniah', 3, 17,
        'The Lord thy God is mighty; he will save, he will rejoice over thee with joy.');
    _addVerse(cache, 'Haggai', 2, 4,
        'Yet now be strong, O Zerubbabel, saith the Lord.');
    _addVerse(cache, 'Zechariah', 4, 6,
        'Not by might, nor by power, but by my spirit.');
    _addVerse(
        cache, 'Malachi', 3, 10, 'Bring the whole tithe into the storehouse.');

    // New Testament
    _addVerse(cache, 'Matthew', 5, 8,
        'Blessed are the pure in heart: for they shall see God.');
    _addVerse(cache, 'Mark', 11, 24,
        'Therefore I say unto you, What things soever ye desire, when ye pray, believe.');
    _addVerse(
        cache, 'Luke', 1, 37, 'For with God nothing shall be impossible.');
    _addVerse(cache, 'John', 3, 16,
        'For God so loved the world, that he gave his only begotten Son.');
    _addVerse(cache, 'Acts', 2, 38,
        'Then Peter said unto them, Repent, and be baptized every one of you.');
    _addVerse(cache, 'Romans', 3, 23,
        'For all have sinned, and come short of the glory of God.');
    _addVerse(
        cache, '1 Corinthians', 13, 4, 'Charity suffereth long, and is kind.');
    _addVerse(cache, '2 Corinthians', 5, 17,
        'Therefore if any man be in Christ, he is a new creature.');
    _addVerse(cache, 'Galatians', 5, 22,
        'But the fruit of the Spirit is love, joy, peace.');
    _addVerse(
        cache, 'Ephesians', 2, 8, 'For by grace are ye saved through faith.');
    _addVerse(cache, 'Philippians', 4, 6,
        'Be careful for nothing; but in every thing by prayer and supplication.');
    _addVerse(cache, 'Colossians', 3, 13,
        'Forbearing one another, and forgiving one another.');
    _addVerse(cache, '1 Thessalonians', 5, 17, 'Pray without ceasing.');
    _addVerse(cache, '2 Thessalonians', 2, 16,
        'Now our Lord Jesus Christ himself, and God, even our Father.');
    _addVerse(cache, '1 Timothy', 6, 10,
        'For the love of money is the root of all evil.');
    _addVerse(cache, '2 Timothy', 2, 2,
        'And the things that thou hast heard of me among many witnesses.');
    _addVerse(cache, 'Titus', 2, 11,
        'For the grace of God that bringeth salvation hath appeared to all men.');
    _addVerse(cache, 'Philemon', 1, 6,
        'That the communication of thy faith may become effectual.');
    _addVerse(cache, 'Hebrews', 11, 1,
        'Now faith is the substance of things hoped for.');
    _addVerse(cache, 'James', 1, 22,
        'But be ye doers of the word, and not hearers only.');
    _addVerse(
        cache, '1 Peter', 3, 15, 'But sanctify the Lord God in your hearts.');
    _addVerse(cache, '2 Peter', 1, 3,
        'According as his divine power hath given unto us all things.');
    _addVerse(cache, '1 John', 1, 9,
        'If we confess our sins, he is faithful and just to forgive us.');
    _addVerse(cache, '2 John', 1, 3, 'Grace be with you, mercy, and peace.');
    _addVerse(cache, '3 John', 1, 2,
        'Beloved, I wish above all things that thou mayest prosper.');
    _addVerse(cache, 'Jude', 1, 2,
        'Mercy unto you, and peace, and love, be multiplied.');
    _addVerse(cache, 'Revelation', 21, 4,
        'And God shall wipe away all tears from their eyes.');

    return cache;
  }

  void _addVerse(Map<String, Map<BibleVersion, BibleVerse>> cache,
      String bookName, int chapter, int verse, String text) {
    final refKey = '$bookName $chapter:$verse';
    cache[refKey] = {
      BibleVersion.kjv: BibleVerse(
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        version: BibleVersion.kjv,
      ),
      BibleVersion.niv: BibleVerse(
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        version: BibleVersion.niv,
      ),
      BibleVersion.nlt: BibleVerse(
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        version: BibleVersion.nlt,
      ),
      BibleVersion.amplified: BibleVerse(
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        version: BibleVersion.amplified,
      ),
      BibleVersion.gnb: BibleVerse(
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        version: BibleVersion.gnb,
      ),
      BibleVersion.esv: BibleVerse(
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        version: BibleVersion.esv,
      ),
    };
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('bible_favorites');

    if (favoritesJson != null) {
      try {
        final decoded = jsonDecode(favoritesJson) as List<dynamic>;
        _favorites.clear();
        _favorites.addAll(
          decoded
              .map((e) => BibleVerse.fromJson(
                  Map<String, dynamic>.from(e as Map<String, dynamic>)))
              .toList(),
        );
      } catch (e) {
        _favorites.clear();
      }
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_favorites.map((v) => v.toJson()).toList());
    await prefs.setString('bible_favorites', json);
  }

  Future<BibleVerse?> getVerse(String reference,
      {BibleVersion? version}) async {
    final targetVersion = version ?? _selectedVersion;

    // Check local cache first
    final verse = _getOfflineVerse(reference, targetVersion);
    if (verse != null) return verse;

    // Try online API with URL-safe reference
    final encodedRef = Uri.encodeComponent(reference.trim());
    try {
      final response = await _dio.get(
        'https://bible-api.com/$encodedRef',
        options: Options(receiveTimeout: const Duration(seconds: 6)),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return BibleVerse(
          bookName: data['bookname'] as String? ?? 'Unknown',
          chapter: data['chapter'] as int? ?? 0,
          verse: data['verse'] as int? ?? 0,
          text: data['text'] as String? ?? '',
          version: targetVersion,
        );
      }
    } catch (e) {
      // If network fails, fall back to offline cache result (may be null)
    }

    return verse;
  }

  BibleVerse? _getOfflineVerse(String reference, BibleVersion version) {
    if (_localBibleCache.containsKey(reference)) {
      final verses = _localBibleCache[reference];
      if (verses != null && verses.containsKey(version)) {
        return verses[version];
      }
      return verses?.values.first;
    }

    final lowerRef = reference.toLowerCase();
    for (final entry in _localBibleCache.entries) {
      if (entry.key.toLowerCase() == lowerRef) {
        final verses = entry.value;
        return verses.containsKey(version)
            ? verses[version]
            : verses.values.first;
      }
    }

    for (final entry in _localBibleCache.entries) {
      if (entry.key.toLowerCase().contains(lowerRef)) {
        final verses = entry.value;
        return verses.containsKey(version)
            ? verses[version]
            : verses.values.first;
      }
    }

    return null;
  }

  Future<void> toggleFavorite(BibleVerse verse) async {
    final index = _favorites.indexWhere(
      (v) => v.reference == verse.reference && v.version == verse.version,
    );

    if (index != -1) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(verse);
    }
    await _saveFavorites();
  }

  bool isFavorite(String reference, BibleVersion version) {
    return _favorites
        .any((v) => v.reference == reference && v.version == version);
  }

  List<BibleVerse> getFavorites() => _favorites;

  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveFavorites();
  }

  BibleVerse? getRandomVerse({BibleVersion? version}) {
    final targetVersion = version ?? _selectedVersion;

    if (_localBibleCache.isEmpty) {
      return null;
    }

    final allVerses = _localBibleCache.values
        .map((versionMap) => versionMap[targetVersion])
        .whereType<BibleVerse>()
        .toList();

    if (allVerses.isEmpty) {
      return _localBibleCache.values.first.values.first;
    }

    return allVerses[DateTime.now().day % allVerses.length];
  }

  Future<List<BibleVerse>> searchVerses(String query,
      {BibleVersion? version}) async {
    final lowerQuery = query.toLowerCase();
    final targetVersion = version ?? _selectedVersion;
    final results = <BibleVerse>[];
    for (final versionMap in _localBibleCache.values) {
      final verse = versionMap[targetVersion];
      if (verse != null) {
        if (verse.reference.toLowerCase().contains(lowerQuery) ||
            verse.text.toLowerCase().contains(lowerQuery) ||
            verse.bookName.toLowerCase().contains(lowerQuery)) {
          results.add(verse);
        }
      }
    }
    // If no local results, try online API (bible-api.com)
    if (results.isEmpty) {
      try {
        final response = await _dio.get('https://bible-api.com/$query');
        if (response.statusCode == 200 && response.data['verses'] != null) {
          for (final v in response.data['verses']) {
            results.add(BibleVerse(
              bookName: v['book_name'] ?? '',
              chapter: v['chapter'] ?? 0,
              verse: v['verse'] ?? 0,
              text: v['text'] ?? '',
              version: targetVersion,
            ));
          }
        }
      } catch (e) {
        // Ignore online errors, just return empty
      }
    }
    return results;
  }

  // Internet search for Bible-related content
  Future<List<Map<String, String>>> searchInternet(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent('$query Bible');
      final response = await _dio.get(
        'https://html.duckduckgo.com/html/?q=$encodedQuery',
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.data);
        final results = <Map<String, String>>[];

        // Parse DuckDuckGo search results
        final resultElements = document.querySelectorAll('.result');

        for (var element in resultElements.take(10)) {
          final titleElement = element.querySelector('.result__title');
          final snippetElement = element.querySelector('.result__snippet');
          final linkElement = element.querySelector('.result__url');

          if (titleElement != null && snippetElement != null) {
            results.add({
              'title': titleElement.text.trim(),
              'snippet': snippetElement.text.trim(),
              'url': linkElement?.text.trim() ?? '',
            });
          }
        }

        return results;
      }
    } catch (e) {
      print('Internet search error: $e');
    }

    return [];
  }
}
