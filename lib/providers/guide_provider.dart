import 'package:flutter/foundation.dart';

class GuideProvider extends ChangeNotifier {
  // Example: guide state
  String _currentGuide = '';
  String get currentGuide => _currentGuide;

  void setGuide(String guide) {
    _currentGuide = guide;
    notifyListeners();
  }
}
