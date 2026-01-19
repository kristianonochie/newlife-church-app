import '../../widgets/floating_chat_button.dart';
import '../chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';
import '../../widgets/app_footer.dart';
import '../../services/content_service.dart';
import '../../services/analytics_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final ContentService _contentService = ContentService();
  Map<String, dynamic> _content = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
    AnalyticsService().trackScreenView('about');
  }

  Future<void> _loadContent() async {
    final content = await _contentService.getPageContent('about');
    setState(() {
      _content = content;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/about'),
      appBar: const ChurchAppBar(
        title: 'About',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadContent,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _content['church_name'] ?? 'New Life Community Church',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _content['location'] ?? 'Tonyrefail, Wales',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _content['description'] ?? 'A CHURCH WHO EXISTS TO LOVE GOD AND LOVE PEOPLE',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Our Mission',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _content['mission'] ?? 'To spread the love of God and serve our community.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Our Vision',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _content['vision'] ?? 'A thriving community united in faith.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_content['pastor_name'] != null) ...[                      const SizedBox(height: 24),
                      Text(
                        'Leadership',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pastor: ${_content['pastor_name']}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                const SizedBox(height: 24),
                Text(
                  'Service Times',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _ServiceTimeCard(
                  day: 'Sunday',
                  times: ['11:00 – 12:15 - Morning Celebration', '11:30 – 12:15 - Junior Church'],
                ),
                const SizedBox(height: 12),
                _ServiceTimeCard(
                  day: 'Monday',
                  times: ['10:00 – 12:30 - HUB Cafe'],
                ),
                const SizedBox(height: 12),
                _ServiceTimeCard(
                  day: 'Tuesday',
                  times: [
                    '10:00 – 12:30 - HUB Cafe',
                    '19:00 – 21:00 - Prayer and Bible Study'
                  ],
                ),
                const SizedBox(height: 12),
                _ServiceTimeCard(
                  day: 'Wednesday',
                  times: [
                    '10:00 – 12:30 - HUB Cafe',
                    '19:00 – 20:30 - Warrior Women (last Wednesday of the month)'
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Connect With Us',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialIcon(icon: Icons.facebook, label: 'Facebook'),
                    _SocialIcon(icon: Icons.camera_alt, label: 'Instagram'),
                    _SocialIcon(icon: Icons.videocam, label: 'YouTube'),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.pushNamed('contact'),
                  icon: const Icon(Icons.phone),
                  label: const Text('Get in Touch'),
                ),
                    const SizedBox(height: 16),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      floatingActionButton: FloatingChatButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ChatScreen(role: 'Me'),
          );
        },
      ),
    );
  }
}

class _ServiceTimeCard extends StatelessWidget {
  final String day;
  final List<String> times;

  const _ServiceTimeCard({
    required this.day,
    required this.times,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            ...times.map((time) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(time, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SocialIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
