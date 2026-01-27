// ...existing code for GiveScreen restored...
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/floating_chat_button.dart';
import '../chat/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'dart:ui' as ui; // Unused import removed
// No need for PayPalDonateButton, revert to url_launcher for all platforms

class GiveScreen extends StatefulWidget {
  const GiveScreen({super.key});

  @override
  State<GiveScreen> createState() => _GiveScreenState();
}

class _GiveScreenState extends State<GiveScreen> {
  // bool _isProcessing = false; // Unused field removed

  Future<void> _openPayPalDonation(
      BuildContext context, String givingType) async {
    final url =
        'https://www.paypal.com/donate?hosted_button_id=V56HCXFE46U5E&custom=${Uri.encodeComponent(givingType)}';
    final uri = Uri.parse(url);
    // Always open in external browser on iOS for App Store compliance
    if (kIsWeb) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PayPal.')),
        );
      }
    } else {
      // On iOS and Android, open in external browser only
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PayPal.')),
        );
      }
    }
  }

  // This screen has been removed for App Store compliance.

  String _getGivingDescription(String givingType) {
    switch (givingType) {
      case 'Offering':
        return 'Give a financial offering to support the ministry and work of New Life Community Church.';
      case 'Tithe':
        return 'Return your tithe (10% of income) to support the church\'s mission and community outreach.';
      case 'Support':
        return 'Provide support to help meet the needs of members and community in crisis or hardship.';
      case 'First Fruits':
        return 'Give the first portion of your increase as an act of faith and thanksgiving to God.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/give'),
      appBar: ChurchAppBar(
        title: 'Give to NLCC',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Give Generously',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your generous giving helps us serve the community and advance the kingdom of God.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '"Give, and it will be given to you." - Luke 6:38',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Info text about PayPal redirection
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Donations are handled securely on our website. You will be redirected to your browser to complete your donation.',
                        style: TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              // Giving options grid
              GridView.count(
                crossAxisCount: isMobile ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.2 : 1.1,
                children: [
                  _buildGivingOption(
                    context,
                    icon: Icons.card_giftcard,
                    title: 'Offering',
                    description: 'Give an offering to support our ministry',
                    color: Colors.amber,
                  ),
                  _buildGivingOption(
                    context,
                    icon: Icons.trending_up,
                    title: 'Tithe',
                    description: 'Return your 10% tithe to God\'s work',
                    color: Colors.green,
                  ),
                  _buildGivingOption(
                    context,
                    icon: Icons.favorite,
                    title: 'Support',
                    description: 'Support those in need in our community',
                    color: Colors.red,
                  ),
                  _buildGivingOption(
                    context,
                    icon: Icons.star,
                    title: 'First Fruits',
                    description: 'Give the first of your increase',
                    color: Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Info section
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why Give?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint('Support ministry and outreach programs'),
                    _buildBulletPoint('Help those in crisis and need'),
                    _buildBulletPoint(
                        'Invest in spiritual growth and discipleship'),
                    _buildBulletPoint(
                        'Advance the mission of New Life Community Church'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact info section
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need Help?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'For questions about giving, please contact us:',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '📧 give@newlifecc.co.uk',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '🌐 www.newlifecc.co.uk',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Footer
              const AppFooter(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 7),
      floatingActionButton: FloatingChatButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ChatScreen(role: 'Me'),
          );
        },
      ),
    );
  }

  Widget _buildGivingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _openPayPalDonation(context, title),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _openPayPalDonation(context, title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Give via PayPal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
