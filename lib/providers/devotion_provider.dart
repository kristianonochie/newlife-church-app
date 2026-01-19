import 'package:flutter/foundation.dart';
import '../services/devotion_service.dart';

class DevotionProvider extends ChangeNotifier {
  final DevotionService _devotionService;
  
  Devotion? _currentDevotion;
  List<Devotion> _allDevotions = [];
  bool _isLoading = false;
  String? _error;

  DevotionProvider(this._devotionService) {
    _init();
  }

  Future<void> _init() async {
    await _devotionService.init();
    _loadTodaysDevotion();
  }

  Devotion? get currentDevotion => _currentDevotion;
  List<Devotion> get allDevotions => _allDevotions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadTodaysDevotion() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentDevotion = _devotionService.getTodaysDevotion();
      _allDevotions = _devotionService.getAllDevotions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReflection(String devotionId, String reflection) async {
    try {
      await _devotionService.addUserReflection(devotionId, reflection);
      _currentDevotion = _devotionService.getTodaysDevotion();
      _allDevotions = _devotionService.getAllDevotions();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshDevotions() async {
    await _loadTodaysDevotion();
  }

  Devotion? getDevotionById(String id) {
    return _devotionService.getDevotionById(id);
  }
}
