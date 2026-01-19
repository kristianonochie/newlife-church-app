import 'package:flutter/material.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';

class ContentEditorScreen extends StatefulWidget {
  const ContentEditorScreen({super.key});

  @override
  State<ContentEditorScreen> createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  final _contentService = ContentService();
  String _selectedPage = 'Events';
  Map<String, dynamic> _currentContent = {};
  bool _isLoading = true;
  bool _isSaving = false;
  
  final Map<String, TextEditingController> _controllers = {};
  final List<Map<String, TextEditingController>> _eventControllers = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
  
  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final eventMap in _eventControllers) {
      for (final controller in eventMap.values) {
        controller.dispose();
      }
    }
    _controllers.clear();
    _eventControllers.clear();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    
    final content = await _contentService.getPageContent(_selectedPage);
    
    setState(() {
      _currentContent = content;
      _isLoading = false;
    });
    
    _initializeControllers();
  }
  
  void _initializeControllers() {
    _disposeControllers();
    
    if (_selectedPage == 'Events') {
      final events = _currentContent['events'] as List? ?? [];
      for (final event in events) {
        _eventControllers.add({
          'title': TextEditingController(text: event['title'] ?? ''),
          'time': TextEditingController(text: event['time'] ?? ''),
          'description': TextEditingController(text: event['description'] ?? ''),
          'location': TextEditingController(text: event['location'] ?? ''),
        });
      }
    } else {
      for (final entry in _currentContent.entries) {
        if (entry.value is String) {
          _controllers[entry.key] = TextEditingController(text: entry.value as String);
        }
      }
    }
  }

  Future<void> _saveContent() async {
    setState(() => _isSaving = true);
    
    // Collect data from controllers
    final Map<String, dynamic> updatedContent = {};
    
    if (_selectedPage == 'Events') {
      final List<Map<String, dynamic>> events = [];
      for (final controllerMap in _eventControllers) {
        events.add({
          'title': controllerMap['title']!.text,
          'time': controllerMap['time']!.text,
          'description': controllerMap['description']!.text,
          'location': controllerMap['location']!.text,
          'recurring': true,
        });
      }
      updatedContent['events'] = events;
    } else {
      for (final entry in _controllers.entries) {
        updatedContent[entry.key] = entry.value.text;
      }
    }
    
    final success = await _contentService.savePageContent(_selectedPage, updatedContent);
    
    setState(() => _isSaving = false);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✓ Content saved successfully!' : '❌ Failed to save content'),
        backgroundColor: success ? Colors.green : AppTheme.errorColor,
      ),
    );
  }

  Future<void> _resetContent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Content?'),
        content: const Text('This will restore default content for this page. Your custom changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    await _contentService.resetPageContent(_selectedPage);
    await _loadContent();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Content reset to default'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addEvent() {
    setState(() {
      _eventControllers.add({
        'title': TextEditingController(),
        'time': TextEditingController(),
        'description': TextEditingController(),
        'location': TextEditingController(),
      });
    });
  }

  void _removeEvent(int index) {
    setState(() {
      final controllers = _eventControllers.removeAt(index);
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Page Selector
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Edit Page:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _contentService.getAllPages().map((page) {
                    final isSelected = page == _selectedPage;
                    return ChoiceChip(
                      label: Text(page),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedPage = page);
                        _loadContent();
                      },
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        
        // Content Editor
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Editing: $_selectedPage Page',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: _resetContent,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reset'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _isSaving ? null : _saveContent,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.save),
                                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Content Fields
                          if (_selectedPage == 'Events')
                            _buildEventsEditor()
                          else
                            _buildStandardEditor(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildStandardEditor() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _controllers.entries.map((entry) {
            final isImageField = _isImageField(entry.key);
            final isEmailField = entry.key.contains('email');
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isImageField)
                        const Icon(Icons.image, size: 18, color: Colors.blue),
                      if (isEmailField)
                        const Icon(Icons.email, size: 18, color: Colors.green),
                      if (isImageField || isEmailField)
                        const SizedBox(width: 6),
                      Text(
                        _formatFieldName(entry.key),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: _getHintText(entry.key),
                      helperText: isImageField 
                          ? 'Path to image asset (e.g., assets/images/photo.jpg)' 
                          : isEmailField 
                              ? 'Valid email address'
                              : null,
                      helperMaxLines: 2,
                      prefixIcon: isImageField 
                          ? const Icon(Icons.image_outlined) 
                          : isEmailField 
                              ? const Icon(Icons.email_outlined)
                              : null,
                    ),
                    maxLines: _isLongField(entry.key) ? 4 : 1,
                    keyboardType: isEmailField ? TextInputType.emailAddress : TextInputType.text,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildEventsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Church Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addEvent,
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ..._eventControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controllers = entry.value;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Event ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeEvent(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildEventField('Event Title', controllers['title']!, 'e.g., Sunday Morning Service'),
                  _buildEventField('Time', controllers['time']!, 'e.g., Sunday, 10:30 AM'),
                  _buildEventField('Description', controllers['description']!, 'Brief description', maxLines: 3),
                  _buildEventField('Location', controllers['location']!, 'e.g., Main Sanctuary'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildEventField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hint,
            ),
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
  
  String _formatFieldName(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
  
  bool _isLongField(String key) {
    return key.contains('description') || 
           key.contains('mission') || 
           key.contains('vision') ||
           key.contains('text') ||
           key.contains('message') ||
           key.contains('guidelines') ||
           key.contains('address');
  }

  bool _isImageField(String key) {
    return key.contains('image') || 
           key.contains('photo') || 
           key.contains('picture') ||
           key.contains('icon') ||
           key.contains('avatar') ||
           key.contains('logo') ||
           key.contains('background');
  }

  String _getHintText(String key) {
    if (_isImageField(key)) {
      return 'assets/images/...';
    }
    if (key.contains('email')) {
      return 'email@example.com';
    }
    if (key.contains('phone')) {
      return '+44 1234 567890';
    }
    if (key.contains('url') || key.contains('website')) {
      return 'https://example.com';
    }
    return 'Enter ${_formatFieldName(key).toLowerCase()}';
  }
}
