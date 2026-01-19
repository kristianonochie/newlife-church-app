import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/guide_provider.dart';
import '../../../core/models/guide.dart';
import '../../widgets/app_bottom_nav.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuideProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Support & Downloads')),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  ...provider.guides.map(
                    (Guide guide) => Card(
                      child: ListTile(
                        title: Text(guide.title),
                        trailing: const Icon(Icons.download),
                        onTap: () async {
                          final uri = Uri.parse(guide.url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Internal Support Ticket'),
                    onPressed: () async {
                      const url =
                          'https://www.conceptfiresec.com/support-ticket';
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
