import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/chat_service.dart';
import '../../services/email_service.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String role;
  final String? userEmail;
  final bool sendTranscript;
  
  const ChatScreen({
    super.key,
    required this.role,
    this.userEmail,
    this.sendTranscript = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _emailService = EmailService();
  bool _submitting = false;
  String? _userName;
  bool _nameCollected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatSession();
    });
  }

  Future<void> _loadChatSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('chat_user_name');
      
      if (savedName != null && savedName.isNotEmpty) {
        // User has a saved session, restore it
        setState(() {
          _userName = savedName;
          _nameCollected = true;
        });
      } else {
        // No saved session, ask for name
        _showNameDialog();
      }
    } catch (e) {
      // If loading fails, show name dialog
      _showNameDialog();
    }
  }

  Future<void> _saveChatSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_userName != null) {
        await prefs.setString('chat_user_name', _userName!);
      }
    } catch (e) {
      print('Error saving chat session: $e');
    }
  }

  Future<void> _showNameDialog() async {
    final nameController = TextEditingController(text: _userName == 'Guest' ? '' : _userName);
    
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Welcome to NLCChat!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Before we start, please tell us your name so we can personalize your chat experience.'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setDialogState(() {});
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      _userName = value.trim();
                      _nameCollected = true;
                    });
                    _saveChatSession();
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _userName = 'Guest';
                  _nameCollected = true;
                });
                _saveChatSession();
                Navigator.pop(context, false);
              },
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: nameController.text.trim().isEmpty
                  ? null
                  : () {
                      setState(() {
                        _userName = nameController.text.trim();
                        _nameCollected = true;
                      });
                      _saveChatSession();
                      Navigator.pop(context, true);
                    },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _endChat(ChatService chat) async {
    if (chat.messages.isEmpty) {
      if (mounted) {
        context.goNamed('home');
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Chat'),
        content: widget.sendTranscript && widget.userEmail != null
            ? const Text('Are you sure you want to end this chat? A transcript will be sent to your email.')
            : const Text('Are you sure you want to end this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Chat'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Send email if option is enabled
    if (widget.sendTranscript && widget.userEmail != null && widget.userEmail!.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sending your chat transcript...'),
            ],
          ),
        ),
      );

      final success = await _emailService.sendChatTranscript(
        recipientEmail: widget.userEmail!,
        userName: widget.role,
        messages: chat.messages,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Chat transcript has been sent to your email!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Could not send transcript. Please try again or contact us.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    }

    // Clear chat and go home
    chat.clear();
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatService>(context);
    return Column(
      children: [
        // End Chat Button Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${chat.messages.length} messages',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  if (_userName != null)
                    Text(
                      'Chatting as: $_userName',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
              const Spacer(),
              if (_userName != null)
                TextButton.icon(
                  onPressed: () {
                    _showNameDialog();
                  },
                  icon: const Icon(Icons.person, size: 16),
                  label: const Text('Change Name'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _endChat(chat),
                icon: const Icon(Icons.exit_to_app, size: 18),
                label: const Text('End Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: chat.messages.length,
            itemBuilder: (context, i) {
              final msg = chat.messages[chat.messages.length - 1 - i];
              final isUserMessage = msg.senderId == 'me';
              return Container(
                alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isUserMessage ? AppTheme.primaryColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUserMessage ? (_userName ?? 'You') : 'NLCChat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUserMessage ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg.content,
                            style: TextStyle(
                              color: isUserMessage ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (msg.escalated)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(Icons.warning, color: Colors.red, size: 16),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _submitting || !_nameCollected ? null : () async {
                  if (_controller.text.trim().isEmpty) return;
                  setState(() => _submitting = true);
                  await chat.sendMessage(ChatMessage(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    senderId: 'me',
                    role: _userName ?? 'User',
                    content: _controller.text.trim(),
                    timestamp: DateTime.now(),
                    attachments: [],
                    escalated: false,
                  ));
                  _controller.clear();
                  setState(() => _submitting = false);
                },
              ),
              IconButton(
                icon: const Icon(Icons.upload_file),
                onPressed: () {}, // TODO: implement upload
              ),
              IconButton(
                icon: const Icon(Icons.warning),
                onPressed: () {
                  // Escalate last message
                  if (chat.messages.isNotEmpty) {
                    chat.escalate(chat.messages.last.id);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
