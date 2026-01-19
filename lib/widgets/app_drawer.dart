import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/newlife_logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.church,
                      size: 48,
                      color: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'New Life Community Church',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tonyrefail',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.home,
            title: 'Home',
            subtitle: 'Welcome & Overview',
            route: 'home',
            routePath: '/',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.favorite,
            title: 'Devotion',
            subtitle: 'Read & Reflect',
            route: 'devotion',
            routePath: '/devotion',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.menu_book,
            title: 'Bible',
            subtitle: 'Search Scripture',
            route: 'bible',
            routePath: '/bible',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.event,
            title: 'Event',
            subtitle: 'Service Schedule',
            route: 'events',
            routePath: '/events',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.church,
            title: 'Prayer',
            subtitle: 'Share Your Needs',
            route: 'prayer',
            routePath: '/prayer',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.volunteer_activism,
            title: 'Give',
            subtitle: 'Support & Giving',
            route: 'give',
            routePath: '/give',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.live_tv,
            title: 'TV',
            subtitle: 'Live & Past Sermons',
            route: 'watch',
            routePath: '/watch',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.groups,
            title: 'About',
            subtitle: 'Our Mission & Vision',
            route: 'about',
            routePath: '/about',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.phone,
            title: 'Contact',
            subtitle: 'Get In Touch',
            route: 'contact',
            routePath: '/contact',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Updates & Alerts',
            route: 'notifications',
            routePath: '/notifications',
          ),
          const Divider(height: 1),
          _buildDrawerItem(
            context: context,
            icon: Icons.chat,
            title: 'NLCChat',
            subtitle: 'Ask about services, Bible, church info',
            route: 'nlcchat',
            routePath: '/nlcchat',
          ),
          const Divider(height: 1),
          _buildDrawerItem(
            context: context,
            icon: Icons.admin_panel_settings,
            title: 'Admin',
            subtitle: 'Manage Notifications',
            route: 'admin',
            routePath: '/admin',
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required String routePath,
  }) {
    final isSelected = currentRoute == routePath || currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          context.goNamed(route);
        }
      },
    );
  }
}
