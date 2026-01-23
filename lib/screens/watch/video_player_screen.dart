import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// Platform-conditional web helpers (web-only implementation selected on web)
import 'video_player_web_helpers.dart'
    if (dart.library.html) 'video_player_web_impl.dart' as web;
// import '../../theme/app_theme.dart'; // Unused import removed
import '../../widgets/church_app_bar.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const VideoPlayerScreen({
    required this.videoUrl,
    required this.videoTitle,
    super.key,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isNativePlatform = false;
  late final String _iframeId;

  @override
  void initState() {
    super.initState();
    // Generate unique iframe ID based on video URL to prevent caching
    _iframeId = 'video-player-${widget.videoUrl.hashCode}';
    _checkPlatform();
    if (_isNativePlatform) {
      _initWebView();
    } else {
      _registerIframeView();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  /// Extract YouTube video ID from various URL formats
  String? _getYouTubeVideoId(String url) {
    // Format: https://www.youtube.com/watch?v=VIDEO_ID
    final regExp1 =
        RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)');
    final match1 = regExp1.firstMatch(url);
    if (match1 != null) return match1.group(1);

    // Format: https://www.youtube.com/@channel/live
    if (url.contains('/live')) {
      // For live streams, try to extract channel ID or use as-is
      return null; // Will use full URL
    }

    return null;
  }

  /// Convert YouTube URL to embeddable format
  String _getYouTubeEmbedUrl(String url) {
    final videoId = _getYouTubeVideoId(url);
    if (videoId != null) {
      return 'https://www.youtube.com/embed/$videoId?autoplay=1&modestbranding=1';
    }
    // For live streams and other formats, use nocookie domain
    if (url.contains('youtube.com/@') || url.contains('/live')) {
      return 'https://www.youtube-nocookie.com/embed/live_stream?channel=${_extractChannelId(url)}&autoplay=1';
    }
    return url;
  }

  /// Extract YouTube channel ID from channel URL
  String _extractChannelId(String url) {
    // This is a simplified extraction; for production, use proper YouTube API
    // For now, we'll return a placeholder and use the channel parameter
    return 'UCYourChannelId'; // Placeholder
  }

  void _checkPlatform() {
    try {
      _isNativePlatform = Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      _isNativePlatform = false;
    }
  }

  void _registerIframeView() {
    final embedUrl = _getYouTubeEmbedUrl(widget.videoUrl);
    web.registerIframeView(_iframeId, embedUrl);
  }

  void _initWebView() {
    final embedUrl = _getYouTubeEmbedUrl(widget.videoUrl);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ChurchAppBar(
        title: widget.videoTitle,
        showBackButton: true,
      ),
      body: _isNativePlatform ? _buildNativePlayer() : _buildWebPlayer(),
    );
  }

  Widget _buildNativePlayer() {
    return Stack(
      children: [
        if (_hasError)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Failed to load video',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _initWebView();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else
          WebViewWidget(controller: _webViewController),
        if (_isLoading)
          Container(
            color: Colors.black87,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildWebPlayer() {
    return web.buildWebPlayerWidget(
      context: context,
      title: widget.videoTitle,
      iframeId: _iframeId,
      onBack: () => Navigator.of(context).pop(),
      onOpenExternal: _openInFacebook,
      hasError: _hasError,
      onRetry: () {
        setState(() {
          _hasError = false;
          _isLoading = true;
        });
        _registerIframeView();
      },
    );
  }

  Future<void> _openInFacebook() async {
    final uri = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video')),
        );
      }
    }
  }
}
