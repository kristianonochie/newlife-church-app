import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/floating_chat_button.dart';
import '../chat/chat_screen.dart';
import '../../services/payment_service.dart';

class GiveScreen extends StatefulWidget {
  const GiveScreen({super.key});

  @override
  State<GiveScreen> createState() => _GiveScreenState();
}

class _GiveScreenState extends State<GiveScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  void _showGivingDialog(BuildContext context, String givingType) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$givingType - New Life Community Church'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getGivingDescription(givingType),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (£)',
                  hintText: 'Enter amount to give',
                  prefixText: '£ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 20, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Secure payment processing via Stripe. Your money goes directly to NLCC bank account.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final amountStr = amountController.text.trim();

                    if (name.isEmpty || email.isEmpty || amountStr.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    final amount = double.tryParse(amountStr);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount')),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await _processPayment(
                      context,
                      givingType: givingType,
                      amount: amount,
                      name: name,
                      email: email,
                    );
                  },
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Pay Securely'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context, {
    required String givingType,
    required double amount,
    required String name,
    required String email,
  }) async {
    setState(() => _isProcessing = true);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing your giving...'),
            ],
          ),
        ),
      );

      // Step 1: Create payment intent on backend
      final paymentIntentResult = await _paymentService.createPaymentIntent(
        amount: amount,
        currency: 'gbp',
        givingType: givingType,
        donorName: name,
        donorEmail: email,
      );

      if (!mounted) return;

      if (!paymentIntentResult['success']) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${paymentIntentResult['error']}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }

      final clientSecret = paymentIntentResult['client_secret'];
      final paymentIntentId = paymentIntentResult['payment_intent_id'];

      // Step 2: Initialize payment sheet
      final initialized = await _paymentService.initializePaymentSheet(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'New Life Community Church',
        amount: amount.toString(),
      );

      if (!mounted) return;

      if (!initialized) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize payment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }

      Navigator.pop(context); // Close loading dialog

      // Step 3: Display payment sheet
      final paymentResult = await _paymentService.displayPaymentSheet(
        context: context,
      );

      if (!mounted) return;

      if (paymentResult['cancelled'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }

      if (!paymentResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${paymentResult['error']}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }

      // Step 4: Complete giving and send receipt
      await _paymentService.completeGiving(
        paymentIntentId: paymentIntentId,
        amount: amount,
        givingType: givingType,
        donorEmail: email,
      );

      if (!mounted) return;

      // Success!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Thank you for your $givingType of £$amount! A receipt has been sent to $email.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

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
                    _buildBulletPoint('Invest in spiritual growth and discipleship'),
                    _buildBulletPoint('Advance the mission of New Life Community Church'),
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
      onTap: () => _showGivingDialog(context, title),
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
                  onPressed: () => _showGivingDialog(context, title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Give Now'),
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
