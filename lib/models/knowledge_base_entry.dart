class KnowledgeBaseEntry {
  final String id;
  final String title;
  final String content;
  final List<double> embedding;
  final List<String> tags;

  KnowledgeBaseEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.embedding,
    required this.tags,
  });
}
