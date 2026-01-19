import 'package:flutter/material.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for installation checklists
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Installation Checklists', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.checklist),
            title: Text('CCTV System Checklist'),
            subtitle: Text('Pre-commissioning and handover steps.'),
          ),
          ListTile(
            leading: Icon(Icons.checklist),
            title: Text('Fire Alarm Checklist'),
            subtitle: Text('BS5839 compliance and safety.'),
          ),
        ],
      ),
    );
  }
}
