import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../core/models/blog_post.dart';

class BlogProvider extends ChangeNotifier {
  List<BlogPost> posts = [];
  bool isLoading = true;

  BlogProvider() {
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final String data = await rootBundle.loadString('lib/data/fixtures/blog.json');
      final List<dynamic> jsonResult = json.decode(data);
      posts = jsonResult.map((e) => BlogPost.fromJson(e)).toList();
    } catch (e) {
      posts = [];
    }
    isLoading = false;
    notifyListeners();
  }
}
