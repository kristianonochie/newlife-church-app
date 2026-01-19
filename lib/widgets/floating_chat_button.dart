import 'package:flutter/material.dart';

class FloatingChatButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FloatingChatButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.chat),
    );
  }
}
