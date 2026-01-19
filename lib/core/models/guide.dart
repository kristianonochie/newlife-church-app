class Guide {
  final String id;
  final String title;
  final String url;

  Guide({required this.id, required this.title, required this.url});

  factory Guide.fromJson(Map<String, dynamic> json) => Guide(
        id: json['id'] as String,
        title: json['title'] as String,
        url: json['url'] as String,
      );
}
