import '../../widgets/floating_chat_button.dart';
import '../chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
                              'Who We Are',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'New Life Community Church is an Assemblies of God church who exists to love God and love people – displaying that love by our actions.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What We Believe',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Our Core Beliefs',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'We accept the Bible as the inspired Word of God, our authoritative guide in all aspects of faith and practice. We believe in the Trinity of God the Father, Son, and Holy Spirit, who are each fully God. We affirm the need for a personal relationship with God, made possible through the work of Christ and received through repentance, faith, baptism in water, and the gift of the Holy Spirit.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Our Mission and Hope',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'We embrace Christ’s commission to preach the good news to all, recognizing the church as the company of those who respond to the gospel message. We look forward to Christ’s personal return. This is not intended to be a comprehensive statement of all we believe as Christians but serves to show our belief in the fundamental truths that have undergirded the Christian faith from its inception more than 2,000 years ago through to this present day.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frequently Asked Questions',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text('Is there disabled access?',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                                'Yes, there is a disabled ramp, disabled toilet and disabled lift.',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text(
                                'Is there a mother and baby changing facility?',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                                'Yes, this is situated in the disabled toilet.',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text('Is there car parking?',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                                'Although no specific car park, there is ample parking on road and a public car park a few metres from the church.',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text('What can my children do in church?',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                                'There is a children’s group that takes place during the church service from toddlers and those attending primary school. All our staff have had DRB checks.',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_content['pastor_name'] != null) ...[
                      const SizedBox(height: 24),
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
                      times: [
                        '11:00 – 12:15 - Morning Celebration',
                        '11:30 – 12:15 - Junior Church'
                      ],
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
                    const SizedBox(height: 12),
                    _ServiceTimeCard(
                      day: 'Thursday',
                      times: [
                        '10:00 – 12:30 - HUB Cafe',
                        '18:00 – 19:30 - Kids Club',
                        '19:30 – 21:00 - Youth Group',
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
                        _SocialIcon(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          onTap: () => _launchUrl(
                              'https://www.facebook.com/newlifecommunitychurchton/'),
                        ),
                        _SocialIcon(
                          icon: Icons.camera_alt,
                          label: 'Instagram',
                          onTap: () => _launchUrl(
                              'https://www.instagram.com/newlifetonyrefail/'),
                        ),
                        _SocialIcon(
                          icon: Icons.videocam,
                          label: 'YouTube',
                          onTap: () => _launchUrl(
                              'https://www.youtube.com/@newlifecommunitychurchtony3427/videos'),
                        ),
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
                      const Icon(Icons.schedule,
                          size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(time,
                              style: Theme.of(context).textTheme.bodySmall)),
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
  final VoidCallback? onTap;

  const _SocialIcon({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}
