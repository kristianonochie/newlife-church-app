class Service {
  final String id;
  final String title;
  final String description;
  final String? icon;

  Service({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String?,
      );
}
