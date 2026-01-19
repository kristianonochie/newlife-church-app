import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: ListView(
          children: const [
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Head Office'),
              subtitle: Text('Concept Securities, 123 Main St, City, UK'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('+44 1234 567890'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('info@conceptfiresec.com'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}
