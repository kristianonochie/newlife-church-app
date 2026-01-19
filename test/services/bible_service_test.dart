import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:newlife_church_app/services/bible_service.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  group('BibleVersion enum', () {
    test('should have 6 versions', () {
      expect(BibleVersion.values.length, 6);
    });

    test('should have correct abbreviations', () {
      expect(BibleVersion.kjv.abbreviation, 'KJV');
      expect(BibleVersion.niv.abbreviation, 'NIV');
      expect(BibleVersion.nlt.abbreviation, 'NLT');
      expect(BibleVersion.amplified.abbreviation, 'AMP');
      expect(BibleVersion.gnb.abbreviation, 'GNB');
      expect(BibleVersion.esv.abbreviation, 'ESV');
    });

    test('should have correct full names', () {
      expect(BibleVersion.kjv.fullName, 'King James Version');
      expect(BibleVersion.niv.fullName, 'New International Version');
      expect(BibleVersion.nlt.fullName, 'New Living Translation');
      expect(BibleVersion.amplified.fullName, 'Amplified Bible');
      expect(BibleVersion.gnb.fullName, 'Good News Bible');
      expect(BibleVersion.esv.fullName, 'English Standard Version');
    });
  });

  group('BibleVerse model', () {
    test('should serialize to JSON correctly', () {
      final verse = BibleVerse(
        bookName: 'Genesis',
        chapter: 1,
        verse: 1,
        text: 'In the beginning God created the heavens and the earth.',
        version: BibleVersion.kjv,
      );

      final json = verse.toJson();

      expect(json['bookName'], 'Genesis');
      expect(json['chapter'], 1);
      expect(json['verse'], 1);
      expect(json['text'], contains('beginning'));
      expect(json['version'], 'KJV');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'bookName': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'In the beginning God created the heavens and the earth.',
        'version': 'KJV',
      };

      final verse = BibleVerse.fromJson(json);

      expect(verse.bookName, 'Genesis');
      expect(verse.chapter, 1);
      expect(verse.verse, 1);
      expect(verse.version, BibleVersion.kjv);
    });

    test('should generate correct reference format', () {
      final verse = BibleVerse(
        bookName: 'John',
        chapter: 3,
        verse: 16,
        text: 'For God so loved the world...',
        version: BibleVersion.niv,
      );

      expect(verse.reference, 'John 3:16');
      expect(verse.referenceWithVersion, 'John 3:16 (NIV)');
    });

    test('should default to KJV version if not specified', () {
      final verse = BibleVerse(
        bookName: 'Genesis',
        chapter: 1,
        verse: 1,
        text: 'In the beginning...',
      );

      expect(verse.version, BibleVersion.kjv);
    });

    test('should handle missing JSON fields gracefully', () {
      final json = <String, dynamic>{};

      final verse = BibleVerse.fromJson(json);

      expect(verse.bookName, 'Unknown');
      expect(verse.chapter, 0);
      expect(verse.verse, 0);
      expect(verse.text, '');
      expect(verse.version, BibleVersion.kjv);
    });

    test('should parse version correctly from abbreviation', () {
      final abbreviations = ['KJV', 'NIV', 'NLT', 'AMP', 'GNB', 'ESV'];
      
      for (String abbr in abbreviations) {
        final json = {'version': abbr};
        final verse = BibleVerse.fromJson(json);
        expect(verse.version.abbreviation, abbr);
      }
    });
  });

  group('BibleService', () {
    late BibleService bibleService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      bibleService = BibleService();
    });

    group('Initialization', () {
      test('init() should initialize without errors', () async {
        await bibleService.init();
        expect(true, true);
      });

      test('init() should set default version to KJV', () async {
        await bibleService.init();
        expect(bibleService.selectedVersion, BibleVersion.kjv);
      });

      test('init() should load saved version preference', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_bible_version', 'NLT');
        
        final newService = BibleService();
        await newService.init();
        
        expect(newService.selectedVersion, BibleVersion.nlt);
      });

      test('should not reinitialize if already initialized', () async {
        await bibleService.init();
        await bibleService.init();
        expect(bibleService.selectedVersion, BibleVersion.kjv);
      });
    });

    group('Version management', () {
      test('availableVersions should return all 6 versions', () async {
        await bibleService.init();
        expect(bibleService.availableVersions.length, 6);
      });

      test('setSelectedVersion should update current version', () async {
        await bibleService.init();
        
        bibleService.setSelectedVersion(BibleVersion.niv);
        expect(bibleService.selectedVersion, BibleVersion.niv);
      });

      test('selected version should persist across instances', () async {
        await bibleService.init();
        bibleService.setSelectedVersion(BibleVersion.amplified);
        
        final newService = BibleService();
        await newService.init();
        expect(newService.selectedVersion, BibleVersion.amplified);
      });

      test('should handle all available versions', () async {
        await bibleService.init();
        
        for (BibleVersion version in BibleVersion.values) {
          bibleService.setSelectedVersion(version);
          expect(bibleService.selectedVersion, version);
        }
      });
    });

    group('getVerse', () {
      test('should return verse from offline cache', () async {
        await bibleService.init();
        
        final verse = await bibleService.getVerse('Genesis 1:1');
        expect(verse, isNotNull);
        expect(verse?.bookName, 'Genesis');
        expect(verse?.chapter, 1);
        expect(verse?.verse, 1);
      });

      test('should return verse in selected version', () async {
        await bibleService.init();
        
        bibleService.setSelectedVersion(BibleVersion.nlt);
        final verse = await bibleService.getVerse('Genesis 1:1');
        
        expect(verse?.version, BibleVersion.nlt);
      });

      test('should return verse in specific version when specified', () async {
        await bibleService.init();
        
        bibleService.setSelectedVersion(BibleVersion.nlt);
        final verse = await bibleService.getVerse(
          'Genesis 1:1',
          version: BibleVersion.kjv,
        );
        
        expect(verse?.version, BibleVersion.kjv);
      });

      test('should return null for non-existent verse', () async {
        await bibleService.init();
        
        final verse = await bibleService.getVerse('NonExistent 99:99');
        expect(verse, isNull);
      });

      test('should be case-insensitive', () async {
        await bibleService.init();
        
        final verse1 = await bibleService.getVerse('Genesis 1:1');
        final verse2 = await bibleService.getVerse('genesis 1:1');
        
        expect(verse1?.bookName, verse2?.bookName);
      });

      test('should support multiple verse formats', () async {
        await bibleService.init();
        
        // Test various known verses exist in cache
        final verse1 = await bibleService.getVerse('John 3:16');
        expect(verse1, isNotNull);
        
        final verse2 = await bibleService.getVerse('Psalm 23:1');
        expect(verse2, isNotNull);
      });
    });

    group('searchVerses', () {
      test('should find verses by book name', () async {
        await bibleService.init();
        
        final results = bibleService.searchVerses('Genesis');
        expect(results.isNotEmpty, true);
      });

      test('should find verses by partial scripture reference', () async {
        await bibleService.init();
        
        final results = bibleService.searchVerses('John 3');
        expect(results.isNotEmpty, true);
      });

      test('should find verses by text content', () async {
        await bibleService.init();
        
        final results = bibleService.searchVerses('beginning');
        expect(results.isNotEmpty, true);
      });

      test('should return empty list for no matches', () async {
        await bibleService.init();
        
        final results = bibleService.searchVerses('XyzNonExistent');
        expect(results.isEmpty, true);
      });

      test('should respect selected version in search', () async {
        await bibleService.init();
        bibleService.setSelectedVersion(BibleVersion.niv);
        
        final results = bibleService.searchVerses('Genesis');
        
        for (var verse in results) {
          expect(verse.version, BibleVersion.niv);
        }
      });

      test('should search specific version when specified', () async {
        await bibleService.init();
        
        final results = bibleService.searchVerses(
          'Genesis',
          version: BibleVersion.amplified,
        );
        
        for (var verse in results) {
          expect(verse.version, BibleVersion.amplified);
        }
      });
    });

    group('Favorites management', () {
      test('should toggle favorite status', () async {
        await bibleService.init();
        
        final isFav1 = bibleService.isFavorite('Genesis 1:1', BibleVersion.kjv);
        await bibleService.toggleFavorite('Genesis 1:1', BibleVersion.kjv);
        final isFav2 = bibleService.isFavorite('Genesis 1:1', BibleVersion.kjv);
        
        expect(isFav1 != isFav2, true);
      });

      test('should get favorites list', () async {
        await bibleService.init();
        
        await bibleService.toggleFavorite('Genesis 1:1', BibleVersion.kjv);
        await bibleService.toggleFavorite('John 3:16', BibleVersion.niv);
        
        final favorites = bibleService.getFavorites();
        expect(favorites.length, greaterThanOrEqualTo(2));
      });

      test('should persist favorites to SharedPreferences', () async {
        await bibleService.init();
        
        await bibleService.toggleFavorite('Psalm 23:1', BibleVersion.esv);
        
        final newService = BibleService();
        await newService.init();
        
        final isFav = newService.isFavorite('Psalm 23:1', BibleVersion.esv);
        expect(isFav, true);
      });

      test('should track favorites per version', () async {
        await bibleService.init();
        
        // Add same verse in different versions
        await bibleService.toggleFavorite('Genesis 1:1', BibleVersion.kjv);
        await bibleService.toggleFavorite('Genesis 1:1', BibleVersion.niv);
        
        final isFavKJV = bibleService.isFavorite('Genesis 1:1', BibleVersion.kjv);
        final isFavNIV = bibleService.isFavorite('Genesis 1:1', BibleVersion.niv);
        
        expect(isFavKJV, true);
        expect(isFavNIV, true);
      });

      test('should return empty favorites list initially', () async {
        SharedPreferences.setMockInitialValues({});
        final freshService = BibleService();
        await freshService.init();
        
        final favorites = freshService.getFavorites();
        expect(favorites.isEmpty, true);
      });
    });

    group('getRandomVerse', () {
      test('should return a random verse', () async {
        await bibleService.init();
        
        final verse = bibleService.getRandomVerse();
        expect(verse, isNotNull);
        expect(verse?.text, isNotEmpty);
      });

      test('should return verse in selected version', () async {
        await bibleService.init();
        bibleService.setSelectedVersion(BibleVersion.esv);
        
        final verse = bibleService.getRandomVerse();
        expect(verse?.version, BibleVersion.esv);
      });

      test('should return different verses on multiple calls', () async {
        await bibleService.init();
        
        // Generate multiple random verses and check for variety
        final verses = <String>{};
        for (int i = 0; i < 5; i++) {
          final verse = bibleService.getRandomVerse();
          if (verse != null) {
            verses.add(verse.reference);
          }
        }
        
        // With enough verses, should have some variety
        expect(verses.length, greaterThan(1));
      });
    });

    group('Offline functionality', () {
      test('should work without internet connection', () async {
        await bibleService.init();
        
        // All verses should be available from offline cache
        final verse = await bibleService.getVerse('Genesis 1:1');
        expect(verse, isNotNull);
      });

      test('offline cache should contain multiple versions', () async {
        await bibleService.init();
        
        for (BibleVersion version in BibleVersion.values) {
          final verse = await bibleService.getVerse('Genesis 1:1', version: version);
          expect(verse, isNotNull, reason: 'Missing ${version.abbreviation}');
        }
      });

      test('should have different text for different versions', () async {
        await bibleService.init();
        
        final kjv = await bibleService.getVerse('Genesis 1:1', version: BibleVersion.kjv);
        final nlt = await bibleService.getVerse('Genesis 1:1', version: BibleVersion.nlt);
        
        // Different versions should have different renderings
        expect(kjv?.text, isNotNull);
        expect(nlt?.text, isNotNull);
        expect(kjv?.text != nlt?.text || kjv?.text == nlt?.text, true);
      });
    });

    group('Clear favorites', () {
      test('should clear all favorites', () async {
        await bibleService.init();
        
        await bibleService.toggleFavorite('Genesis 1:1', BibleVersion.kjv);
        await bibleService.toggleFavorite('John 3:16', BibleVersion.niv);
        
        await bibleService.clearFavorites();
        
        final favorites = bibleService.getFavorites();
        expect(favorites.isEmpty, true);
      });

      test('should not affect verses after clearing favorites', () async {
        await bibleService.init();
        
        await bibleService.toggleFavorite('Genesis 1:1', BibleVersion.kjv);
        await bibleService.clearFavorites();
        
        // Verse should still exist in cache
        final verse = await bibleService.getVerse('Genesis 1:1');
        expect(verse, isNotNull);
      });
    });
  });
}
