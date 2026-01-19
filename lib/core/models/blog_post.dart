class BlogPost {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String date;

  BlogPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
        id: json['id'] as String,
        title: json['title'] as String,
        excerpt: json['excerpt'] as String,
        content: json['content'] as String,
        date: json['date'] as String,
      );
}
