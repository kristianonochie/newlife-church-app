import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Developed by NLCC Tech Team',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                // Use GoRouter for navigation to support web and mobile
                // ignore: use_build_context_synchronously
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                // Use GoRouter navigation
                // ignore: use_build_context_synchronously
                // context.go('/privacy');
                // To avoid context issues, use GoRouter.of(context).go
                GoRouter.of(context).go('/privacy');
              },
              child: Text(
                'Privacy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
