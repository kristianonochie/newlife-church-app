class ChatMessage {
  final String id;
  final String senderId;
  final String role;
  final String content;
  final DateTime timestamp;
  final List<String> attachments;
  final bool escalated;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.attachments,
    required this.escalated,
  });
}
