import 'package:flutter/material.dart';
import '../../../core/models/service.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Service service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: ListView(
          children: [
            Text(
              service.title,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            Text(
              service.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // Add more details or images as needed
          ],
        ),
      ),
    );
  }
}
