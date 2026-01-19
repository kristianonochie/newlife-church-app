import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  User? _currentUser;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  User? get currentUser => _currentUser;
  int get failedAttempts => _failedAttempts;
  DateTime? get lockedUntil => _lockedUntil;

  Future<bool> login(String username, String password) async {
    // DEMO: Load credentials from secure storage (not hardcoded)
    // In production, fetch from backend
    final storedHash = await _storage.read(key: 'engineer_password_hash');
    final passwordChanged = await _storage.read(key: 'engineer_password_changed') == 'true';
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      return false;
    }
    if (username == 'Engineer' && storedHash != null && _verifyPassword(password, storedHash)) {
      _currentUser = User(
        id: '1',
        username: username,
        role: 'Engineer',
        passwordHash: storedHash,
        passwordChanged: passwordChanged,
        failedAttempts: 0,
        lockedUntil: null,
        auditLog: [],
      );
      _failedAttempts = 0;
      notifyListeners();
      return true;
    } else {
      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _lockedUntil = DateTime.now().add(const Duration(minutes: 15));
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    // Store hash, mark as changed
    await _storage.write(key: 'engineer_password_hash', value: _hashPassword(newPassword));
    await _storage.write(key: 'engineer_password_changed', value: 'true');
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        role: _currentUser!.role,
        passwordHash: _hashPassword(newPassword),
        passwordChanged: true,
        failedAttempts: 0,
        lockedUntil: null,
        auditLog: _currentUser!.auditLog,
      );
    }
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  bool _verifyPassword(String password, String hash) {
    // Simple hash check for demo; use bcrypt/argon2 in production
    return _hashPassword(password) == hash;
  }

  String _hashPassword(String password) {
    // Simple hash for demo; use a secure hash in production
    return password.split('').reversed.join();
  }
}
