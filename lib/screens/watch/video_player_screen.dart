import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../theme/app_theme.dart';
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
    final regExp1 = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)');
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
    print('Registering iframe: $_iframeId with URL: $embedUrl'); // Debug log
    
    // Register iframe view for web platform with unique ID
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = embedUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
          ..allowFullscreen = true;
        return iframe;
      },
    );
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
      body: _isNativePlatform
          ? _buildNativePlayer()
          : _buildWebPlayer(),
    );
  }

  Widget _buildNativePlayer() {
    return Stack(
      children: [
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
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Video Title
                  Text(
                    widget.videoTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Embedded Video Player
                  Container(
                    height: 600,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryColor, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: HtmlElementView(viewType: _iframeId),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Back Button
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Services'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Alternative: Open in Facebook
                  OutlinedButton.icon(
                    onPressed: _openInFacebook,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in Facebook App'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
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
