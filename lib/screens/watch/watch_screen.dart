import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';
import '../../widgets/app_footer.dart';
import '../../services/content_service.dart';
import '../../services/youtube_service.dart';
import 'video_player_screen.dart';
import 'live_waiting_screen.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  final _contentService = ContentService();
  // NOTE: Replace these with your actual YouTube API key and channel ID
  // Get API key from: https://console.cloud.google.com/
  // Channel ID from your channel's "About" section
  final _youtubeService = YouTubeService(
    apiKey: 'YOUR_YOUTUBE_API_KEY_HERE', // TODO: Add your API key
    channelId: 'UCYourChannelIDHere', // TODO: Add your channel ID
  );
  
  Map<String, dynamic> _content = {};
  bool _isLoading = true;
  List<YouTubeVideo> _pastVideos = [];
  List<YouTubeVideo> _liveVideos = [];
  bool _fetchingVideos = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _fetchYouTubeVideos();
  }

  Future<void> _loadContent() async {
    final content = await _contentService.getPageContent('Watch');
    setState(() {
      _content = content;
      _isLoading = false;
    });
    // If API key isn't configured, use fallback past_videos from content
    if (!_youtubeService.isConfigured) {
      _loadFallbackVideos();
    }
  }

  Future<void> _fetchYouTubeVideos() async {
    // Only fetch if API key is configured
    if (!_youtubeService.isConfigured) {
      print('YouTube API key not configured. Using fallback videos.');
      return;
    }

    setState(() {
      _fetchingVideos = true;
    });

    try {
      final pastVideos = await _youtubeService.getChannelVideos(maxResults: 10);
      final liveVideos = await _youtubeService.getLiveVideos();

      setState(() {
        _pastVideos = pastVideos;
        _liveVideos = liveVideos;
        _fetchingVideos = false;
      });

      // If API returns no past videos, fall back to provided list
      if (pastVideos.isEmpty) {
        _loadFallbackVideos();
      }
    } catch (e) {
      print('Error fetching YouTube videos: $e');
      setState(() {
        _fetchingVideos = false;
      });
      _loadFallbackVideos();
    }
  }

  Future<void> _loadFallbackVideos() async {
    final pastVideosRaw = _content['past_videos'];
    final List<YouTubeVideo> parsed = [];

    Future<YouTubeVideo> buildVideo(String title, String url, String date) async {
      String finalTitle = title.isEmpty ? 'Sermon' : title;
      String thumb = '';
      // Try to fetch metadata via YouTube oEmbed (no API key needed)
      if (url.isNotEmpty) {
        try {
          final oEmbed = await Dio().get(
            'https://www.youtube.com/oembed',
            queryParameters: {'format': 'json', 'url': url},
          );
          finalTitle = (oEmbed.data['title'] as String?)?.trim() ?? finalTitle;
          thumb = (oEmbed.data['thumbnail_url'] as String?) ?? '';
        } catch (_) {
          // ignore failures, keep fallback title
        }
      }

      return YouTubeVideo(
        id: _extractYouTubeId(url),
        title: finalTitle,
        description: '',
        thumbnail: thumb,
        publishedAt: DateTime.tryParse(date) ?? DateTime.now(),
        originalUrl: url,
      );
    }

    if (pastVideosRaw is List) {
      for (final item in pastVideosRaw) {
        final map = Map<String, String>.from(item as Map);
        parsed.add(await buildVideo(map['title'] ?? '', map['url'] ?? '', map['date'] ?? ''));
      }
    } else if (pastVideosRaw is String && pastVideosRaw.isNotEmpty) {
      final lines = pastVideosRaw.split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split('|');
        final title = parts.isNotEmpty ? parts[0].trim() : 'Sermon';
        final url = parts.length > 1 ? parts[1].trim() : '';
        final date = parts.length > 2 ? parts[2].trim() : '';
        parsed.add(await buildVideo(title, url, date));
      }
    }

    if (parsed.isNotEmpty) {
      setState(() {
        _pastVideos = parsed;
      });
    }
  }

  String _extractYouTubeId(String url) {
    if (url.isEmpty) return '';
    
    // Handle youtube.com/watch?v=ID format
    final regExp1 = RegExp(r'[?&]v=([^&\n?#]+)');
    final match1 = regExp1.firstMatch(url);
    if (match1 != null && match1.group(1) != null) {
      return match1.group(1)!;
    }
    
    // Handle youtu.be/ID format
    final regExp2 = RegExp(r'youtu\.be/([^&\n?#]+)');
    final match2 = regExp2.firstMatch(url);
    if (match2 != null && match2.group(1) != null) {
      return match2.group(1)!;
    }
    
    // If no match, return empty to indicate error
    return '';
  }

  void _playVideo(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: url,
          videoTitle: title,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pageTitle = _content['page_title'] ?? 'Watch Services';
    final introText = _content['intro_text'] ?? 'Watch our live services and past sermons';
    final liveStreamUrl = _content['live_stream_url'] ?? 'https://www.youtube.com/@newlifecommunitychurchtony3427/live';
    final youtubeChannelUrl = _content['youtube_channel_url'] ?? 'https://www.youtube.com/@newlifecommunitychurchtony3427';

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/watch'),
      appBar: ChurchAppBar(
        title: pageTitle,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Card(
                        color: AppTheme.primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.live_tv,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                pageTitle,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                introText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Live Stream Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.circle, color: Colors.white, size: 12),
                                        SizedBox(width: 6),
                                        Text(
                                          'LIVE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Watch Live Service',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Join us live every Sunday at 11:00 AM. Click the button below to watch our live stream on YouTube.',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (_liveVideos.isNotEmpty) {
                                      _playVideo(
                                        _liveVideos.first.youtubeUrl,
                                        _liveVideos.first.title.isEmpty
                                            ? 'Live Stream'
                                            : _liveVideos.first.title,
                                      );
                                    } else {
                                      // Show waiting screen in app
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const LiveWaitingScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.play_circle_filled),
                                  label: const Text('Watch Live in App'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF0000), // YouTube red
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(16),
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => _launchUrl(youtubeChannelUrl),
                                icon: const Icon(Icons.video_library),
                                label: const Text('Visit Our YouTube Channel'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Past Sermons Section
                      const Text(
                        'Previous Sermons',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_fetchingVideos)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading recent videos...',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else if (_pastVideos.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.video_library, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No past sermons available yet',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _pastVideos.length,
                          itemBuilder: (context, index) {
                            final video = _pastVideos[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    image: video.thumbnail.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(video.thumbnail),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: video.thumbnail.isEmpty
                                      ? const Icon(
                                          Icons.play_circle_outline,
                                          color: AppTheme.primaryColor,
                                          size: 32,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  video.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${video.publishedAt.month}/${video.publishedAt.day}/${video.publishedAt.year}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  _playVideo(video.youtubeUrl, video.title);
                                },
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 24),

                      // Info Card
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Service Times',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '📅 Sunday\n'
                                '  11:00 – 12:15  Morning Celebration\n'
                                '  11:30 – 12:15  Junior Church\n'
                                '🍰 Monday\n'
                                '  10:00 – 12:30  HUB Cafe\n'
                                '🍰 Tuesday\n'
                                '  10:00 – 12:30  HUB Cafe\n'
                                '  19:00 – 21:00  Prayer and Bible Study\n'
                                '🍰 Wednesday\n'
                                '  10:00 – 12:30  HUB Cafe\n'
                                '  19:00 – 20:30  Warrior Women (last Wednesday of the month)\n'
                                '🍰 Thursday\n'
                                '  10:00 – 12:30  HUB Cafe',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue.shade900,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
