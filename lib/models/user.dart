class User {
  final String id;
  final String username;
  final String role;
  final String passwordHash;
  final bool passwordChanged;
  final int failedAttempts;
  final DateTime? lockedUntil;
  final List<String> auditLog;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.passwordHash,
    required this.passwordChanged,
    required this.failedAttempts,
    this.lockedUntil,
    required this.auditLog,
  });
}
