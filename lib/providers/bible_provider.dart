import 'package:flutter/foundation.dart';
import '../services/bible_service.dart';

class BibleProvider extends ChangeNotifier {
  // Search the whole Bible for a query (not just a single verse reference)
  Future<void> searchBible(String query, {BibleVersion? version}) async {
    await searchVerses(query, version: version);
  }

  final BibleService _bibleService;

  BibleVerse? _currentVerse;
  List<BibleVerse> _favoriteVerses = [];
  List<BibleVerse> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  BibleVersion _selectedVersion = BibleVersion.kjv;

  BibleProvider({BibleService? bibleService})
      : _bibleService = bibleService ?? BibleService() {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    try {
      await _bibleService.init();
      _favoriteVerses = List<BibleVerse>.from(_bibleService.getFavorites());
      _selectedVersion = _bibleService.selectedVersion;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Getters
  BibleVerse? get currentVerse => _currentVerse;
  List<BibleVerse> get favoriteVerses =>
      List<BibleVerse>.unmodifiable(_favoriteVerses);
  List<BibleVerse> get searchResults =>
      List<BibleVerse>.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  BibleVersion get selectedVersion => _selectedVersion;
  List<BibleVersion> get availableVersions => BibleVersion.values;

  // Actions
  void setSelectedVersion(BibleVersion version) {
    _selectedVersion = version;
    _bibleService.setSelectedVersion(version);
    notifyListeners();
  }

  Future<void> searchVerse(String reference, {BibleVersion? version}) async {
    if (reference.isEmpty) return;
    _setLoading(true);
    _error = null;
    _searchQuery = reference;
    try {
      final verse = await _bibleService.getVerse(reference,
          version: version ?? _selectedVersion);
      if (verse == null) {
        _currentVerse = null;
        _error =
            'No verse found for "$reference". Try another reference like "John 3:16".';
      } else {
        _currentVerse = verse;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> searchVerses(String query, {BibleVersion? version}) async {
    _setLoading(true);
    _error = null;
    _searchQuery = query;
    try {
      final results = await _bibleService.searchVerses(query,
          version: version ?? _selectedVersion);
      _searchResults = List<BibleVerse>.from(results);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  bool isFavorite(BibleVerse verse) => _favoriteVerses
      .any((v) => v.reference == verse.reference && v.version == verse.version);

  Future<void> toggleFavorite(BibleVerse verse) async {
    try {
      await _bibleService.toggleFavorite(verse);
      _favoriteVerses = List<BibleVerse>.from(_bibleService.getFavorites());
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> getRandomVerse({BibleVersion? version}) async {
    _setLoading(true);
    _error = null;
    try {
      final verse =
          _bibleService.getRandomVerse(version: version ?? _selectedVersion);
      _currentVerse = verse;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    try {
      await _bibleService.clearFavorites();
      _favoriteVerses = List<BibleVerse>.from(_bibleService.getFavorites());
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}
