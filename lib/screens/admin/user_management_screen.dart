import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();
  
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSuperAdmin = false;
  List<Map<String, dynamic>> _users = [];
  
  String _selectedRole = 'admin';
  int _selectedPriority = 1;
  Set<String> _selectedRestrictions = {};
  
  Map<String, dynamic>? _editingUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    final isSuper = await _adminService.isSuperAdmin();
    final users = await _adminService.listAdmins();

    setState(() {
      _isSuperAdmin = isSuper;
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _adminService.createAdminUser(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      priority: _selectedPriority,
      restrictions: _selectedRestrictions.toList(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✓ User created successfully'
            : '✗ Failed to create user (may already exist)'),
        backgroundColor: success ? Colors.green : AppTheme.errorColor,
      ),
    );

    if (success) {
      _clearForm();
      await _loadUsers();
    }
  }

  Future<void> _updateUser(String username) async {
    setState(() => _isLoading = true);

    final success = await _adminService.updateAdminUser(
      username: username,
      newPassword: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      role: _selectedRole,
      priority: _selectedPriority,
      restrictions: _selectedRestrictions.toList(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✓ User updated' : '✗ Update failed'),
        backgroundColor: success ? Colors.green : AppTheme.errorColor,
      ),
    );

    if (success) {
      _clearForm();
      await _loadUsers();
    }
  }

  Future<void> _deleteUser(String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user "$username"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final success = await _adminService.deleteAdminUser(username);

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✓ User deleted' : '✗ Cannot delete this user'),
        backgroundColor: success ? Colors.green : AppTheme.errorColor,
      ),
    );

    if (success) {
      await _loadUsers();
    }
  }

  void _editUser(Map<String, dynamic> user) {
    setState(() {
      _editingUser = user;
      _usernameController.text = user['username'];
      _passwordController.clear(); // Don't show existing password
      _selectedRole = user['role'];
      _selectedPriority = user['priority'];
      _selectedRestrictions = Set<String>.from(user['restrictions'] ?? []);
    });
  }

  void _clearForm() {
    setState(() {
      _editingUser = null;
      _usernameController.clear();
      _passwordController.clear();
      _selectedRole = 'admin';
      _selectedPriority = 1;
      _selectedRestrictions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSuperAdmin) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Only superadmin can manage users',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.people, size: 32, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Management',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Create and manage admin users with custom privileges',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (_editingUser != null)
                    TextButton.icon(
                      onPressed: _clearForm,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel Edit'),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Create/Edit User Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingUser == null ? 'Create New User' : 'Edit User',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Username
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          enabled: _editingUser == null, // Can't change username when editing
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username is required';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: _editingUser == null ? 'Password *' : 'New Password (leave blank to keep current)',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (_editingUser == null && (value == null || value.isEmpty)) {
                              return 'Password is required';
                            }
                            if (value != null && value.isNotEmpty && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Role & Priority Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                  DropdownMenuItem(value: 'editor', child: Text('Editor')),
                                  DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedRole = value ?? 'admin');
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedPriority,
                                decoration: const InputDecoration(
                                  labelText: 'Priority Level',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(
                                  10,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1} ${i == 9 ? '(Highest)' : i == 0 ? '(Lowest)' : ''}'),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() => _selectedPriority = value ?? 1);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Restrictions
                        const Text(
                          'Restrictions (check to DENY access)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AdminService.getAvailablePermissions().map((permission) {
                            final key = permission['key']!;
                            final label = permission['label']!;
                            final isRestricted = _selectedRestrictions.contains(key);

                            return FilterChip(
                              label: Text(label),
                              selected: isRestricted,
                              selectedColor: Colors.red.shade100,
                              checkmarkColor: Colors.red,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedRestrictions.add(key);
                                  } else {
                                    _selectedRestrictions.remove(key);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_editingUser == null) {
                                      _createUser();
                                    } else {
                                      _updateUser(_editingUser!['username']);
                                    }
                                  },
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(_editingUser == null ? Icons.add : Icons.save),
                            label: Text(_editingUser == null ? 'Create User' : 'Update User'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Users List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Existing Users (${_users.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_users.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No users found', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            final username = user['username'];
                            final role = user['role'];
                            final priority = user['priority'];
                            final restrictions = List<String>.from(user['restrictions'] ?? []);
                            final isSuperadmin = role == 'superadmin';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSuperadmin ? Colors.amber : AppTheme.primaryColor,
                                child: Icon(
                                  isSuperadmin ? Icons.star : Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    username,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSuperadmin ? Colors.amber : Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      role.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Priority: $priority',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              subtitle: restrictions.isEmpty
                                  ? const Text('No restrictions (full access)')
                                  : Text('Restricted: ${restrictions.length} permissions'),
                              trailing: isSuperadmin
                                  ? Chip(
                                      label: const Text('Protected', style: TextStyle(fontSize: 10)),
                                      backgroundColor: Colors.grey.shade300,
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _editUser(user),
                                          tooltip: 'Edit User',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteUser(username),
                                          tooltip: 'Delete User',
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
