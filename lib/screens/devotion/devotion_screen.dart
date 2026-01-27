import '../../widgets/floating_chat_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/devotion_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import '../../widgets/church_app_bar.dart';
import 'package:go_router/go_router.dart';

class DevotionScreen extends StatefulWidget {
  const DevotionScreen({super.key});

  @override
  State<DevotionScreen> createState() => _DevotionScreenState();
}

class _DevotionScreenState extends State<DevotionScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year, 1, 1),
      lastDate: DateTime(DateTime.now().year, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/devotion'),
      appBar: ChurchAppBar(
        title: 'Devotion',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: Consumer<DevotionProvider>(
        builder: (context, devotionProvider, _) {
          final devotions = devotionProvider.allDevotions;

          // Filter devotions by selected date
          final devotionsForDate = devotions.where((d) {
            return d.date.year == _selectedDate.year &&
                d.date.month == _selectedDate.month &&
                d.date.day == _selectedDate.day;
          }).toList();

          if (devotions.isEmpty) {
            return const Center(child: Text('No devotions available'));
          }

          return Column(
            children: [
              // Inspirational Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.light_mode_rounded,
                          color: Colors.amber[300],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Start Your Day with God\'s Word',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✦ Why Daily Devotions Matter:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Strengthen your faith through Scripture and reflection\n• Connect with God\'s Word every single day\n• Find guidance, encouragement, and peace\n• Deepen your relationship with Christ\n• Build spiritual discipline and consistency',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.95),
                                      height: 1.6,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"Your word is a lamp to my feet and a light to my path." - Psalm 119:105',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.amber[100],
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Single Devotional Link with Navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Devotional',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Previous Day Button
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate
                                    .subtract(const Duration(days: 1));
                              });
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                            color: AppTheme.primaryColor,
                            tooltip: 'Previous Day',
                          ),
                        ),
                        // Current Devotion Link
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.primaryColor,
                                width: 1.5,
                              ),
                              color: AppTheme.primaryColor.withOpacity(0.08),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              leading: Icon(
                                Icons.calendar_today,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              title: Text(
                                DateFormat('MMM d, yyyy').format(_selectedDate),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: devotionsForDate.isNotEmpty
                                  ? Text(
                                      devotionsForDate[0].title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                    )
                                  : Text(
                                      'No devotion available',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        // Next Day Button
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate =
                                    _selectedDate.add(const Duration(days: 1));
                              });
                            },
                            icon: const Icon(Icons.arrow_forward_ios),
                            color: AppTheme.primaryColor,
                            tooltip: 'Next Day',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Date display banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy')
                              .format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          devotionsForDate.isEmpty
                              ? 'No devotion for this date'
                              : 'Tap to read today\'s devotion',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate
                                  .subtract(const Duration(days: 1));
                            });
                          },
                          tooltip: 'Previous Day',
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedDate =
                                  _selectedDate.add(const Duration(days: 1));
                            });
                          },
                          tooltip: 'Next Day',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Devotions list
              Expanded(
                child: devotionsForDate.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No devotion for this date',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select another date from the calendar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: devotionsForDate.length,
                        itemBuilder: (context, index) {
                          final devotion = devotionsForDate[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              leading: Icon(
                                Icons.book_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              title: Text(
                                devotion.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                devotion.scripture,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                              onTap: () {
                                context.pushNamed(
                                  'devotion-detail',
                                  pathParameters: {'id': devotion.id},
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              // Quick Links at bottom
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Bible Quick Link
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.goNamed('bible'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
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
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      persistentFooterButtons: const [AppFooter()],
      floatingActionButton: FloatingChatButton(
        onPressed: () {
          context.goNamed('nlcchat');
        },
      ),
    );
  }
}
