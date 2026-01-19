import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/devotion_provider.dart';
import '../../services/email_service.dart';
import '../../services/devotion_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';
import '../../widgets/floating_chat_button.dart';

class DevotionDetailScreen extends StatefulWidget {
  final String devotionId;

  const DevotionDetailScreen({
    super.key,
    required this.devotionId,
  });

  @override
  State<DevotionDetailScreen> createState() => _DevotionDetailScreenState();
}

class _DevotionDetailScreenState extends State<DevotionDetailScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  final EmailService _emailService = EmailService();

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  void _showSendDevotionDialog(
    BuildContext context, {
    required String devotionTitle,
    required String devotionScripture,
    required String devotionBody,
    required String devotionAuthor,
    required String reflection,
  }) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Devotion & Reflection'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final firstName = firstNameController.text;
              final email = emailController.text;

              if (firstName.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final success = await _emailService.sendDevotionEmail(
                toEmail: email,
                firstName: firstName,
                devotionTitle: devotionTitle,
                devotionScripture: devotionScripture,
                devotionBody: devotionBody,
                devotionAuthor: devotionAuthor,
                reflection: reflection,
                submittedDate: DateTime.now().toString(),
              );

              if (mounted) {
                Navigator.pop(context); // Close loading dialog

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Devotion sent successfully to your email!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ Could not send devotion. Please try again or contact us.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/devotion'),
      appBar: const ChurchAppBar(
        title: 'Devotion Details',
        showBackButton: true,
      ),
      body: Consumer<DevotionProvider>(
        builder: (context, devotionProvider, _) {
          final devotions = devotionProvider.allDevotions;

          if (devotions.isEmpty) {
            return const Center(
              child: Text('No devotions available right now.'),
            );
          }

          final devotion = devotions.firstWhere(
            (d) => d.id == widget.devotionId,
            orElse: () => devotions.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCombinedPage(context, devotion, devotionProvider),
          );
        },
      ),
      floatingActionButton: FloatingChatButton(
        onPressed: () => context.goNamed('nlcchat'),
      ),
    );
  }

  Widget _buildCombinedPage(
    BuildContext context,
    Devotion devotion,
    DevotionProvider devotionProvider,
  ) {
    final devotions = devotionProvider.allDevotions;
    final currentIndex = devotions.indexWhere((d) => d.id == devotion.id);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < devotions.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation arrows at the top
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: hasPrevious ? AppTheme.primaryColor : Colors.grey[300],
              ),
              onPressed: hasPrevious
                  ? () {
                      final previousDevotion = devotions[currentIndex - 1];
                      context.goNamed('devotion-detail', pathParameters: {'id': previousDevotion.id});
                    }
                  : null,
              tooltip: hasPrevious ? 'Previous Day' : 'No previous devotion',
            ),
            Text(
              'Day Navigation',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: hasNext ? AppTheme.primaryColor : Colors.grey[300],
              ),
              onPressed: hasNext
                  ? () {
                      final nextDevotion = devotions[currentIndex + 1];
                      context.goNamed('devotion-detail', pathParameters: {'id': nextDevotion.id});
                    }
                  : null,
              tooltip: hasNext ? 'Next Day' : 'No next devotion',
            ),
          ],
        ),
        const Divider(height: 24),

        Text(
          devotion.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            devotion.scripture,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'By: ${devotion.author}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        
        // Date display
        Text(
          devotion.date.toString().split(' ')[0], // Format: YYYY-MM-DD
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),

        // Main devotion body
        Text(
          devotion.body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),

        // Story / reflection narrative
        if (devotion.story != null && devotion.story!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueGrey[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_stories, size: 18, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Story',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  devotion.story!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Thoughts / reflection prompt
        if (devotion.thoughts != null && devotion.thoughts!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.purple[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lightbulb_outline, size: 18, color: AppTheme.secondaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Thoughts',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.secondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  devotion.thoughts!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Action challenge
        if (devotion.action != null && devotion.action!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Action',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  devotion.action!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Confession / prayer
        if (devotion.confession != null && devotion.confession!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.favorite_border, size: 18, color: Colors.deepOrange),
                    SizedBox(width: 8),
                    Text(
                      'Confession / Prayer',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.deepOrange),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  devotion.confession!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'Your Reflection & Response',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (devotion.reflection != null && devotion.reflection!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Previous Reflection:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(devotion.reflection!),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        TextField(
          controller: _reflectionController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Write your thoughts, prayers, and reflections on this devotion...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_reflectionController.text.isNotEmpty) {
                    await devotionProvider.addReflection(
                      devotion.id,
                      _reflectionController.text,
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Reflection saved!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _reflectionController.clear();
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: devotion.reflection != null && devotion.reflection!.isNotEmpty
                    ? () => _showSendDevotionDialog(
                          context,
                          devotionTitle: devotion.title,
                          devotionScripture: devotion.scripture,
                          devotionBody: devotion.body,
                          devotionAuthor: devotion.author,
                          reflection: devotion.reflection ?? '',
                        )
                    : null,
                icon: const Icon(Icons.send),
                label: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: devotion.reflection != null && devotion.reflection!.isNotEmpty
                      ? AppTheme.primaryColor
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        
        // Quick Access Links at Bottom
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              // Bible Quick Link
              Expanded(
                child: GestureDetector(
                  onTap: () => context.goNamed('bible'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bible',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Give Quick Link
              Expanded(
                child: GestureDetector(
                  onTap: () => context.goNamed('give'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Give',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
