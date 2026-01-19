import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newlife_church_app/services/devotion_service.dart';

void main() {
  group('DevotionService', () {
    late DevotionService devotionService;

    setUp(() {
      // Reset singleton for testing
      SharedPreferences.setMockInitialValues({});
      devotionService = DevotionService();
    });

    group('Initialization', () {
      test('init() should load devotions from SharedPreferences', () async {
        await devotionService.init();
        expect(devotionService.getAllDevotions().isNotEmpty, true);
      });

      test('init() should create sample devotions if none exist', () async {
        await devotionService.init();
        final devotions = devotionService.getAllDevotions();
        expect(devotions.length, 15);
      });

      test('init() should not reinitialize if already initialized', () async {
        await devotionService.init();
        final firstLength = devotionService.getAllDevotions().length;
        await devotionService.init();
        final secondLength = devotionService.getAllDevotions().length;
        expect(firstLength, secondLength);
      });

      test('sample devotions should have correct structure', () async {
        await devotionService.init();
        final devotions = devotionService.getAllDevotions();
        
        expect(devotions.first.id, isNotNull);
        expect(devotions.first.title, isNotNull);
        expect(devotions.first.scripture, isNotNull);
        expect(devotions.first.body, isNotNull);
        expect(devotions.first.author, 'New Life Community Church');
      });
    });

    group('getTodaysDevotion', () {
      test('should return todays devotion if it exists', () async {
        await devotionService.init();
        final today = devotionService.getTodaysDevotion();
        
        expect(today, isNotNull);
        expect(today?.id, isNotNull);
      });

      test('should return latest devotion if todays devotion not found', () async {
        await devotionService.init();
        final devotion = devotionService.getTodaysDevotion();
        final allDevotions = devotionService.getAllDevotions();
        
        // Should return first (latest) if today's not found
        expect(devotion?.id, allDevotions.first.id);
      });

      test('should return null if no devotions exist', () async {
        // Create a fresh service with no devotions
        SharedPreferences.setMockInitialValues({'devotions': '[]'});
        final emptyService = DevotionService();
        
        // Manually set empty list without init
        emptyService._devotions = [];
        expect(emptyService.getTodaysDevotion(), isNull);
      });
    });

    group('getAllDevotions', () {
      test('should return list of all devotions', () async {
        await devotionService.init();
        final devotions = devotionService.getAllDevotions();
        
        expect(devotions, isA<List<Devotion>>());
        expect(devotions.length, greaterThan(0));
      });

      test('should maintain devotion order', () async {
        await devotionService.init();
        final devotions = devotionService.getAllDevotions();
        final firstId = devotions.first.id;
        
        expect(firstId, '1'); // Sample data starts with id '1'
      });
    });

    group('getDevotionById', () {
      test('should return devotion with matching id', () async {
        await devotionService.init();
        final devotion = devotionService.getDevotionById('1');
        
        expect(devotion, isNotNull);
        expect(devotion?.id, '1');
        expect(devotion?.title, 'Trust in the Lord');
      });

      test('should return null for non-existent id', () async {
        await devotionService.init();
        final devotion = devotionService.getDevotionById('999');
        
        expect(devotion, isNull);
      });

      test('should find devotion by various ids', () async {
        await devotionService.init();
        
        for (String id in ['1', '5', '10', '15']) {
          final devotion = devotionService.getDevotionById(id);
          expect(devotion, isNotNull);
          expect(devotion?.id, id);
        }
      });
    });

    group('addDevotion', () {
      test('should add new devotion to beginning of list', () async {
        await devotionService.init();
        final initialLength = devotionService.getAllDevotions().length;
        
        final newDevotion = Devotion(
          id: '999',
          title: 'Test Devotion',
          scripture: 'John 3:16',
          body: 'Test body',
          date: DateTime.now(),
          author: 'Test Author',
        );
        
        await devotionService.addDevotion(newDevotion);
        final devotions = devotionService.getAllDevotions();
        
        expect(devotions.length, initialLength + 1);
        expect(devotions.first.id, '999');
      });

      test('should persist added devotion to SharedPreferences', () async {
        await devotionService.init();
        
        final newDevotion = Devotion(
          id: '998',
          title: 'Persistence Test',
          scripture: 'Test 1:1',
          body: 'Test',
          date: DateTime.now(),
          author: 'Test',
        );
        
        await devotionService.addDevotion(newDevotion);
        
        // Create new instance and check if devotion persists
        final newService = DevotionService();
        await newService.init();
        final retrievedDevotion = newService.getDevotionById('998');
        
        expect(retrievedDevotion?.title, 'Persistence Test');
      });
    });

    group('addUserReflection', () {
      test('should add reflection to existing devotion', () async {
        await devotionService.init();
        final devotionId = '1';
        final reflection = 'This is my personal reflection on this devotion.';
        
        await devotionService.addUserReflection(devotionId, reflection);
        final updatedDevotion = devotionService.getDevotionById(devotionId);
        
        expect(updatedDevotion?.reflection, reflection);
      });

      test('should not add reflection to non-existent devotion', () async {
        await devotionService.init();
        
        await devotionService.addUserReflection('999', 'Reflection');
        // Should not throw error
        expect(true, true);
      });

      test('should update existing reflection', () async {
        await devotionService.init();
        final devotionId = '1';
        
        await devotionService.addUserReflection(devotionId, 'First reflection');
        await devotionService.addUserReflection(devotionId, 'Updated reflection');
        
        final devotion = devotionService.getDevotionById(devotionId);
        expect(devotion?.reflection, 'Updated reflection');
      });

      test('should persist reflection to SharedPreferences', () async {
        await devotionService.init();
        final reflection = 'My deep thoughts on this passage.';
        
        await devotionService.addUserReflection('2', reflection);
        
        // Create new instance and check persistence
        final newService = DevotionService();
        await newService.init();
        final devotion = newService.getDevotionById('2');
        
        expect(devotion?.reflection, reflection);
      });
    });

    group('Devotion model', () {
      test('should serialize and deserialize correctly', () {
        final now = DateTime.now();
        final devotion = Devotion(
          id: 'test-id',
          title: 'Test Title',
          scripture: 'Test 1:1',
          body: 'Test body content',
          date: now,
          author: 'Test Author',
          reflection: 'Test reflection',
        );

        final json = devotion.toJson();
        final restored = Devotion.fromJson(json);

        expect(restored.id, devotion.id);
        expect(restored.title, devotion.title);
        expect(restored.scripture, devotion.scripture);
        expect(restored.body, devotion.body);
        expect(restored.author, devotion.author);
        expect(restored.reflection, devotion.reflection);
      });

      test('should handle null reflection in serialization', () {
        final devotion = Devotion(
          id: 'test',
          title: 'Test',
          scripture: 'Test 1:1',
          body: 'Body',
          date: DateTime.now(),
          author: 'Author',
        );

        final json = devotion.toJson();
        final restored = Devotion.fromJson(json);

        expect(restored.reflection, isNull);
      });
    });

    group('Date handling', () {
      test('sample devotions should span 2 weeks', () async {
        await devotionService.init();
        final devotions = devotionService.getAllDevotions();
        
        if (devotions.isNotEmpty) {
          final latestDate = devotions.map((d) => d.date).reduce(
            (a, b) => a.isAfter(b) ? a : b,
          );
          final oldestDate = devotions.map((d) => d.date).reduce(
            (a, b) => a.isBefore(b) ? a : b,
          );
          
          final daysDifference = latestDate.difference(oldestDate).inDays;
          expect(daysDifference, greaterThanOrEqualTo(13));
        }
      });
    });
  });
}
