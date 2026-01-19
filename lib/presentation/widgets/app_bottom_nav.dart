import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.goNamed('home');
            break;
          case 1:
            context.goNamed('services');
            break;
          case 2:
            context.goNamed('blog');
            break;
          case 3:
            context.goNamed('support');
            break;
          case 4:
            context.goNamed('contact');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Blog'),
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
        BottomNavigationBarItem(icon: Icon(Icons.contact_mail), label: 'Contact'),
      ],
    );
  }
}
