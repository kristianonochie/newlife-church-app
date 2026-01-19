import 'package:dio/dio.dart';

class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final DateTime publishedAt;
  final String? originalUrl;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.publishedAt,
    this.originalUrl,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>;
    final id = json['id'] as Map<String, dynamic>;
    
    return YouTubeVideo(
      id: id['videoId'] as String? ?? '',
      title: snippet['title'] as String? ?? 'Untitled',
      description: snippet['description'] as String? ?? '',
      thumbnail: (snippet['thumbnails'] as Map<String, dynamic>?)?['high']?['url'] as String? ?? '',
      publishedAt: DateTime.parse(snippet['publishedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  String get youtubeUrl => originalUrl ?? 'https://www.youtube.com/watch?v=$id';
}

class YouTubeService {
  final String _apiKey;
  final String _channelId;
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  YouTubeService({
    required String apiKey,
    required String channelId,
  })  : _apiKey = apiKey,
        _channelId = channelId;

  /// Check if API key is configured
  bool get isConfigured => _apiKey != 'YOUR_YOUTUBE_API_KEY_HERE';

  /// Fetch recent videos from the channel
  /// Returns up to [maxResults] videos (default 10, max 50)
  Future<List<YouTubeVideo>> getChannelVideos({int maxResults = 10}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'key': _apiKey,
          'channelId': _channelId,
          'part': 'snippet',
          'order': 'date',
          'maxResults': maxResults,
          'type': 'video',
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List<dynamic>? ?? [];
        return items
            .map((item) => YouTubeVideo.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching YouTube videos: $e');
      return [];
    }
  }

  /// Fetch live videos from the channel
  Future<List<YouTubeVideo>> getLiveVideos() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'key': _apiKey,
          'channelId': _channelId,
          'part': 'snippet',
          'eventType': 'live',
          'type': 'video',
          'maxResults': 5,
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List<dynamic>? ?? [];
        return items
            .map((item) => YouTubeVideo.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching live videos: $e');
      return [];
    }
  }

  /// Get the most recent upload from the channel (latest video)
  Future<YouTubeVideo?> getLatestVideo() async {
    try {
      final videos = await getChannelVideos(maxResults: 1);
      return videos.isNotEmpty ? videos.first : null;
    } catch (e) {
      print('Error fetching latest video: $e');
      return null;
    }
  }
}
