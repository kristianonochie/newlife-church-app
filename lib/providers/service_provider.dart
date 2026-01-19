import 'package:flutter/foundation.dart';

class ServiceProvider extends ChangeNotifier {
  // Example: service state
  bool _active = false;
  bool get active => _active;

  void activate() {
    _active = true;
    notifyListeners();
  }

  void deactivate() {
    _active = false;
    notifyListeners();
  }
}
