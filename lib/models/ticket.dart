class Ticket {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? escalatedTo;

  Ticket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.escalatedTo,
  });
}
