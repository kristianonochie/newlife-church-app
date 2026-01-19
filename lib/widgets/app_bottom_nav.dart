import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

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
            context.goNamed('devotion');
            break;
          case 2:
            context.goNamed('bible');
            break;
          case 3:
            context.goNamed('events');
            break;
          case 4:
            context.goNamed('about');
            break;
          case 5:
            context.goNamed('prayer');
            break;
          case 6:
            context.goNamed('give');
            break;
          case 7:
            context.goNamed('nlcchat');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.surfaceColor,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Devotion',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Bible',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: 'About',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.church),
          label: 'Prayer',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism),
          label: 'Give',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'NLCChat',
        ),
      ],
    );
  }
}
