import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/admin_service.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_footer.dart';
import 'content_editor_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _newAdminUsernameController = TextEditingController();
  final _newAdminPasswordController = TextEditingController();
  final _newAdminRestrictionsController = TextEditingController();
  final _adminService = AdminService();
  final _analyticsService = AnalyticsService();
  
  late TabController _tabController;
  bool _isLoading = false;
  bool _isLoadingAnalytics = true;
  bool _isSuperAdmin = false;
  bool _isLoadingAdmins = false;
  String _selectedTopic = 'all_users';
  String _newAdminRole = 'admin';
  int _newAdminPriority = 1;
  
  Map<String, dynamic> _analyticsData = {};
  List<Map<String, dynamic>> _admins = [];
  
  final List<Map<String, String>> _topics = [
    {'value': 'all_users', 'label': 'All Users', 'description': 'Send to everyone'},
    {'value': 'announcements', 'label': 'Announcements', 'description': 'General announcements'},
    {'value': 'devotions', 'label': 'Devotions', 'description': 'Daily devotion updates'},
    {'value': 'events', 'label': 'Events', 'description': 'Event notifications'},
    {'value': 'prayer', 'label': 'Prayer', 'description': 'Prayer requests & updates'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
    _loadAdminContext();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _newAdminUsernameController.dispose();
    _newAdminPasswordController.dispose();
    _newAdminRestrictionsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminContext() async {
    setState(() {
      _isLoadingAdmins = true;
    });

    final isSuper = await _adminService.isSuperAdmin();
    List<Map<String, dynamic>> admins = [];
    if (isSuper) {
      admins = await _adminService.listAdmins();
    }

    setState(() {
      _isSuperAdmin = isSuper;
      _admins = admins;
      _isLoadingAdmins = false;
    });
  }

  Future<void> _createAdminUser() async {
    if (!_adminFormKey.currentState!.validate()) return;
    if (!_isSuperAdmin) return;

    setState(() => _isLoadingAdmins = true);

    final restrictions = _newAdminRestrictionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final success = await _adminService.createAdminUser(
      username: _newAdminUsernameController.text.trim(),
      password: _newAdminPasswordController.text,
      role: _newAdminRole,
      priority: _newAdminPriority,
      restrictions: restrictions,
    );

    await _loadAdminContext();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Admin user created'
            : 'User already exists or insufficient permissions'),
        backgroundColor: success ? Colors.green : AppTheme.errorColor,
      ),
    );

    if (success) {
      _newAdminUsernameController.clear();
      _newAdminPasswordController.clear();
      _newAdminRestrictionsController.clear();
      _newAdminPriority = 1;
      _newAdminRole = 'admin';
    }
  }
  
  Future<void> _loadAnalytics() async {
    setState(() => _isLoadingAnalytics = true);
    
    try {
      final data = await _analyticsService.getAggregatedStats();
      setState(() {
        _analyticsData = data;
        _isLoadingAnalytics = false;
      });
    } catch (e) {
      setState(() => _isLoadingAnalytics = false);
      print('Error loading analytics: $e');
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success;
    if (_selectedTopic == 'all_users') {
      success = await _adminService.sendNotificationToAll(
        title: _titleController.text.trim(),
        body: _messageController.text.trim(),
        data: {'type': 'admin_announcement'},
      );
    } else {
      success = await _adminService.sendNotificationToTopic(
        topic: _selectedTopic,
        title: _titleController.text.trim(),
        body: _messageController.text.trim(),
        data: {'type': _selectedTopic},
      );
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Notification sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _titleController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to send notification. Check FCM settings.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await _adminService.logout();
    if (!mounted) return;
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            Tab(icon: Icon(Icons.edit), text: 'Edit Content'),
            Tab(icon: Icon(Icons.people), text: 'Manage Users'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(isMobile),
          _buildNotificationsTab(isMobile),
          const ContentEditorScreen(),
          const UserManagementScreen(),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsTab(bool isMobile) {
    return Column(
      children: [
        Expanded(
          child: _isLoadingAnalytics
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'App Analytics & Monitoring',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Real-time insights and usage statistics',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          
                          // Stats Grid
                          _buildStatsGrid(isMobile),
                          const SizedBox(height: 24),
                          
                          // Feature Usage Chart
                          _buildFeatureUsageSection(),
                          const SizedBox(height: 24),
                          
                          // Additional Info
                          _buildAdditionalInfo(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        const AppFooter(),
      ],
    );
  }
  
  Widget _buildStatsGrid(bool isMobile) {
    final totalSessions = _analyticsData['total_sessions'] ?? 0;
    final daysSinceInstall = _analyticsData['days_since_install'] ?? 0;
    final totalEvents = _analyticsData['total_events'] ?? 0;
    final topFeatures = _analyticsData['top_features'] as List? ?? [];
    final mostUsedFeature = topFeatures.isNotEmpty ? topFeatures[0]['name'] : 'N/A';
    
    final stats = [
      {
        'icon': Icons.download_for_offline,
        'title': 'Total Sessions',
        'value': totalSessions.toString(),
        'color': Colors.blue,
        'subtitle': 'App opens',
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Days Active',
        'value': daysSinceInstall.toString(),
        'color': Colors.green,
        'subtitle': 'Since install',
      },
      {
        'icon': Icons.touch_app,
        'title': 'Total Events',
        'value': totalEvents.toString(),
        'color': Colors.orange,
        'subtitle': 'Interactions tracked',
      },
      {
        'icon': Icons.star,
        'title': 'Top Feature',
        'value': _formatFeatureName(mostUsedFeature),
        'color': Colors.purple,
        'subtitle': 'Most popular',
      },
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stat['icon'] as IconData,
                  size: 40,
                  color: stat['color'] as Color,
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  stat['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFeatureUsageSection() {
    final topFeatures = _analyticsData['top_features'] as List? ?? [];
    
    if (topFeatures.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No usage data yet. Use the app to generate analytics.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Top 5 Most Used Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...topFeatures.map((feature) {
              final name = feature['name'] as String;
              final count = feature['count'] as int;
              final maxCount = topFeatures.first['count'] as int;
              final percentage = maxCount > 0 ? (count / maxCount) : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatFeatureName(name),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$count uses',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdditionalInfo() {
    final installDate = _analyticsData['install_date'] as String?;
    String formattedDate = 'Unknown';
    
    if (installDate != null) {
      final date = DateTime.parse(installDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    }
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Analytics Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('App Installed', formattedDate),
            _buildInfoRow('Tracking Status', 'Active'),
            _buildInfoRow('Data Storage', 'Local (this device)'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Note: These analytics are stored locally on this device. For global app statistics across all users, configure Firebase Analytics in FIREBASE_FCM_ADMIN_SETUP.md',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
  
  String _formatFeatureName(String name) {
    // Convert snake_case to Title Case
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
  
  Widget _buildNotificationsTab(bool isMobile) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Card(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              size: 48,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Push Notification Manager',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Send instant notifications to all church members',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notification Form
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create Notification',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Topic Selection
                              const Text(
                                'Send To:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._topics.map((topic) {
                                return RadioListTile<String>(
                                  value: topic['value']!,
                                  groupValue: _selectedTopic,
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _selectedTopic = value!;
                                          });
                                        },
                                  title: Text(topic['label']!),
                                  subtitle: Text(
                                    topic['description']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 20),

                              // Title Field
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Notification Title',
                                  hintText: 'e.g., Sunday Service Update',
                                  prefixIcon: Icon(Icons.title),
                                  border: OutlineInputBorder(),
                                ),
                                maxLength: 50,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                                enabled: !_isLoading,
                              ),
                              const SizedBox(height: 16),

                              // Message Field
                              TextFormField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  labelText: 'Message',
                                  hintText: 'Enter your announcement message...',
                                  prefixIcon: Icon(Icons.message),
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 5,
                                maxLength: 200,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a message';
                                  }
                                  return null;
                                },
                                enabled: !_isLoading,
                              ),
                              const SizedBox(height: 24),

                              // Send Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _sendNotification,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.send),
                                  label: Text(
                                    _isLoading ? 'Sending...' : 'Send Notification',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Important Information',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '• Notifications are sent instantly to all subscribed users\n'
                              '• Users must have the app installed and notifications enabled\n'
                              '• Title limited to 50 characters, message to 200 characters\n'
                              '• For Firebase FCM setup, see FIREBASE_SETUP.md',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Superadmin admin management
                    if (_isSuperAdmin) ...[
                      const SizedBox(height: 24),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _adminFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Superadmin: Manage Staff Admins',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _newAdminUsernameController,
                                  decoration: const InputDecoration(
                                    labelText: 'New Admin Username',
                                    prefixIcon: Icon(Icons.person_add),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Enter username'
                                      : null,
                                  enabled: !_isLoadingAdmins,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _newAdminPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'New Admin Password',
                                    prefixIcon: Icon(Icons.lock),
                                    border: OutlineInputBorder(),
                                  ),
                                  obscureText: true,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Enter password'
                                      : null,
                                  enabled: !_isLoadingAdmins,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _newAdminRole,
                                  items: const [
                                    DropdownMenuItem(value: 'admin', child: Text('Admin (staff)')),
                                    DropdownMenuItem(value: 'superadmin', child: Text('Superadmin')),
                                  ],
                                  onChanged: _isLoadingAdmins
                                      ? null
                                      : (val) {
                                          setState(() {
                                            _newAdminRole = val ?? 'admin';
                                          });
                                        },
                                  decoration: const InputDecoration(
                                    labelText: 'Role',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  initialValue: '1',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Priority (higher = more access)',
                                    prefixIcon: Icon(Icons.grade),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (v) {
                                    final parsed = int.tryParse(v);
                                    _newAdminPriority = parsed ?? 1;
                                  },
                                  enabled: !_isLoadingAdmins,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _newAdminRestrictionsController,
                                  decoration: const InputDecoration(
                                    labelText: 'Restrictions (comma-separated)',
                                    prefixIcon: Icon(Icons.rule),
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: !_isLoadingAdmins,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoadingAdmins ? null : _createAdminUser,
                                    icon: _isLoadingAdmins
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.save),
                                    label: Text(
                                      _isLoadingAdmins ? 'Saving...' : 'Create Admin',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Existing Admins',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_isLoadingAdmins)
                                const Center(child: CircularProgressIndicator())
                              else if (_admins.isEmpty)
                                const Text('No admin users found.')
                              else
                                ..._admins.map((u) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      u['role'] == 'superadmin'
                                          ? Icons.shield
                                          : Icons.person,
                                      color: AppTheme.primaryColor,
                                    ),
                                    title: Text('${u['username']} (${u['role']})'),
                                    subtitle: Text('Priority: ${u['priority']}  Restrictions: ${u['restrictions']?.join(', ') ?? 'None'}'),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const AppFooter(),
      ],
    );
  }
}
