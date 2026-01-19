import 'package:flutter/material.dart';

class ToolsDownloadsScreen extends StatelessWidget {
  const ToolsDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for tools & downloads
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tools & Downloads', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text('Fire Alarm Wiring Diagram'),
            trailing: Icon(Icons.download),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text('CCTV System Datasheet'),
            trailing: Icon(Icons.download),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
