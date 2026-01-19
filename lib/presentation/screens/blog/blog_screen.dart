import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/blog_provider.dart';
import '../../../core/models/blog_post.dart';
import '../../widgets/app_bottom_nav.dart';
import 'package:go_router/go_router.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Blog')),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: provider.posts.length,
                itemBuilder: (context, i) {
                  final BlogPost post = provider.posts[i];
                  return Card(
                    child: ListTile(
                      title: Text(post.title),
                      subtitle: Text(post.excerpt),
                      trailing: Text(post.date),
                      onTap: () {
                        context.goNamed('blog-detail', extra: post);
                      },
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
