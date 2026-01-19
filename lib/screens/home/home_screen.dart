import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/devotion_provider.dart';
import '../../providers/bible_provider.dart';
import '../../services/content_service.dart';
import '../../services/analytics_service.dart';

import '../../widgets/floating_chat_button.dart';
import '../chat/chat_screen.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';
import '../../widgets/app_footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ContentService _contentService = ContentService();
  Map<String, dynamic> _content = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
    AnalyticsService().trackScreenView('home');
  }

  Future<void> _loadContent() async {
    final content = await _contentService.getPageContent('home');
    setState(() {
      _content = content;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/'),
      appBar: const ChurchAppBar(
        title: 'New Life Community Church',
        showNotificationIcon: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _content['welcome_title'] ?? 'Welcome to New Life Community Church',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _content['welcome_subtitle'] ?? 'A CHURCH WHO EXISTS TO LOVE GOD AND LOVE PEOPLE',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pushNamed('about'),
                      child: const Text('Learn More About Us'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Daily Devotion
            Consumer<DevotionProvider>(
              builder: (context, devotionProvider, _) {
                final devotion = devotionProvider.currentDevotion;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Daily Devotion',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            Icon(Icons.favorite_border,
                                color: AppTheme.primaryColor),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (devotion != null) ...[
                          Text(
                            devotion.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            devotion.scripture,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            devotion.body,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.pushNamed('devotion'),
                            child: const Text('Read Full Devotion'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Bible Verse
            Consumer<BibleProvider>(
              builder: (context, bibleProvider, _) {
                final verse = bibleProvider.currentVerse;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Daily Bible Verse',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            Icon(Icons.menu_book,
                                color: AppTheme.primaryColor),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (verse != null) ...[
                          Text(
                            verse.reference,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            verse.text,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.pushNamed('bible'),
                            child: const Text('Explore Bible'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Links
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                _QuickAccessCard(
                  icon: Icons.favorite,
                  label: 'Devotion',
                  color: AppTheme.primaryColor,
                  onTap: () => context.pushNamed('devotion'),
                ),
                _QuickAccessCard(
                  icon: Icons.live_tv,
                  label: 'TV',
                  color: const Color(0xFFE91E63),
                  onTap: () => context.pushNamed('watch'),
                ),
                _QuickAccessCard(
                  icon: Icons.calendar_today,
                  label: 'Events',
                  color: const Color(0xFF9C27B0),
                  onTap: () => context.pushNamed('events'),
                ),
                _QuickAccessCard(
                  icon: Icons.volunteer_activism,
                  label: 'Give',
                  color: AppTheme.secondaryColor,
                  onTap: () => context.pushNamed('give'),
                ),
                _QuickAccessCard(
                  icon: Icons.groups,
                  label: 'About',
                  color: const Color(0xFF00BCD4),
                  onTap: () => context.pushNamed('about'),
                ),
                _QuickAccessCard(
                  icon: Icons.menu_book,
                  label: 'Bible',
                  color: const Color(0xFF4CAF50),
                  onTap: () => context.pushNamed('bible'),
                ),
                _QuickAccessCard(
                  icon: Icons.church,
                  label: 'Prayer',
                  color: const Color(0xFFFF9800),
                  onTap: () => context.pushNamed('prayer'),
                ),
                _QuickAccessCard(
                  icon: Icons.phone,
                  label: 'Contact',
                  color: const Color(0xFF607D8B),
                  onTap: () => context.pushNamed('contact'),
                ),
              ],
            ),
            const AppFooter(),
          ],
        ),
      ),
      floatingActionButton: FloatingChatButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const SizedBox(
              height: 500,
              child: ChatScreen(role: 'Me'),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
