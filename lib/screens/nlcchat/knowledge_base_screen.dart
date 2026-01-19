import 'package:flutter/material.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for KB search and results
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Knowledge Base', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search Knowledge Base',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('How to commission a fire panel?'),
                  subtitle: Text('Step-by-step guide for safe commissioning.'),
                ),
                ListTile(
                  title: Text('CCTV camera not showing video'),
                  subtitle: Text('Troubleshooting steps for video loss.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
