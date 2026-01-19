import '../models/knowledge_base_entry.dart';

class AIService {
  final List<KnowledgeBaseEntry> _kb;
  AIService(this._kb);

  Future<String> getAnswer(String query, String role) async {
    // Mock RAG: search KB, return answer or escalate
    final match = _kb.firstWhere(
      (e) => e.title.toLowerCase().contains(query.toLowerCase()) ||
              e.content.toLowerCase().contains(query.toLowerCase()),
      orElse: () => KnowledgeBaseEntry(
        id: '0',
        title: 'No Match',
        content: 'Sorry, I could not find a relevant answer. Please clarify or escalate.',
        embedding: [],
        tags: [],
      ),
    );
    if (match.id == '0') {
      return match.content;
    }
    // Add safety disclaimer for engineer role
    if (role == 'Engineer') {
      return '${match.content}\n\n⚠️ Always follow manufacturer manuals and safety standards. For fire/life-safety/high-voltage, escalate if unsure.';
    }
    return match.content;
  }
}
