import 'package:flutter/material.dart';

void registerIframeView(String iframeId, String embedUrl) {
  // No-op on non-web platforms
}

Widget buildWebPlayerWidget({
  required BuildContext context,
  required String title,
  required String iframeId,
  required VoidCallback onBack,
  required Future<void> Function() onOpenExternal,
  bool hasError = false,
  VoidCallback? onRetry,
}) {
  // Fallback on non-web: simple message
  return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ondemand_video, color: Colors.white70, size: 64),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Video playback is available on web or via the in-app player.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    ),
  );
}
