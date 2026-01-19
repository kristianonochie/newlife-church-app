import 'package:flutter/foundation.dart';

class BlogProvider extends ChangeNotifier {
  // Example: blog state
  final List<String> _posts = [];
  List<String> get posts => List.unmodifiable(_posts);

  void addPost(String post) {
    _posts.add(post);
    notifyListeners();
  }
}
