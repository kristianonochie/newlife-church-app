import '../../widgets/floating_chat_button.dart';
import '../chat/chat_screen.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';
import '../../widgets/app_footer.dart';
import '../../services/content_service.dart';
import '../../services/analytics_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _contentService = ContentService();
  final _analyticsService = AnalyticsService();
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _analyticsService.trackScreenView('events');
    _analyticsService.trackFeatureUsage('events');
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    
    final content = await _contentService.getPageContent('Events');
    final events = content['events'] as List? ?? [];
    
    setState(() {
      _events = events.cast<Map<String, dynamic>>();
      _isLoading = false;
    });
  }

  IconData _getIconForEvent(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('sunday') || lowerTitle.contains('service') || lowerTitle.contains('worship')) {
      return Icons.church;
    } else if (lowerTitle.contains('prayer') || lowerTitle.contains('bible')) {
      return Icons.menu_book;
    } else if (lowerTitle.contains('women') || lowerTitle.contains('men') || lowerTitle.contains('group')) {
      return Icons.people;
    } else if (lowerTitle.contains('youth') || lowerTitle.contains('kids')) {
      return Icons.child_care;
    } else if (lowerTitle.contains('cafe') || lowerTitle.contains('coffee')) {
      return Icons.local_cafe;
    } else {
      return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/events'),
      appBar: const ChurchAppBar(
        title: 'Event',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    child: _events.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event_busy,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No events scheduled',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back soon for upcoming events!',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _events.length,
                            itemBuilder: (context, index) {
                              final event = _events[index];
                              final title = event['title'] as String? ?? 'Event';
                              final time = event['time'] as String? ?? '';
                              final description = event['description'] as String? ?? '';
                              final location = event['location'] as String? ?? '';
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getIconForEvent(title),
                                            color: AppTheme.primaryColor,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: Theme.of(context).textTheme.headlineSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (time.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                                            const SizedBox(width: 8),
                                            Text(time),
                                          ],
                                        ),
                                      ],
                                      if (location.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                                            const SizedBox(width: 8),
                                            Text(location),
                                          ],
                                        ),
                                      ],
                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          description,
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
          const AppFooter(),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
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
