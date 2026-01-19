import 'package:flutter/material.dart';
import '../../../core/models/blog_post.dart';

class BlogDetailScreen extends StatelessWidget {
  final BlogPost post;
  const BlogDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: ListView(
          children: [
            Text(post.title, style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(post.date, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
