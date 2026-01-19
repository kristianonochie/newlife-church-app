import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';

class NLCChatScreen extends StatefulWidget {
  const NLCChatScreen({super.key});

  @override
  State<NLCChatScreen> createState() => _NLCChatScreenState();
}

class _NLCChatScreenState extends State<NLCChatScreen> {
  String? userName;
  String? userEmail;
  bool sendTranscript = false;

  @override
  Widget build(BuildContext context) {
    if (userName == null) {
      return Scaffold(
        drawer: const AppDrawer(currentRoute: '/nlcchat'),
        appBar: const ChurchAppBar(
          title: 'NLCChat - Spiritual Companion',
          showBackButton: true,
          showNotificationIcon: false,
        ),
        body: _buildLoginScreen(),
      );
    }

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/nlcchat'),
      appBar: ChurchAppBar(
        title: 'NLCChat - Spiritual Companion',
        showBackButton: true,
        showNotificationIcon: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Welcome, $userName!',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: ChatScreen(
        role: userName ?? 'User',
        userEmail: userEmail,
        sendTranscript: sendTranscript,
      ),
    );
  }

  Widget _buildLoginScreen() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    bool localSendTranscript = false;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Logo
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/newlife_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.chat_bubble,
                      size: 40,
                      color: Colors.blue,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Welcome to NLCChat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your Spiritual Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Name Input Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: StatefulBuilder(
                    builder: (context, setLocalState) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Please enter your details to begin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            hintText: 'Enter your first name',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: const Text(
                            'Send chat transcript to my email',
                            style: TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            'Receive a copy of your conversation when you finish',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          value: localSendTranscript,
                          onChanged: (value) {
                            setLocalState(() {
                              localSendTranscript = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),

                        // Start Chat Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final name = nameController.text.trim();
                              final email = emailController.text.trim();
                              
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter your first name'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter your email address'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              // Basic email validation
                              if (!email.contains('@') || !email.contains('.')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid email address'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              setState(() {
                                userName = name;
                                userEmail = email;
                                sendTranscript = localSendTranscript;
                              });
                            },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Start Chat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Info Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  '✨ NLCChat is your spiritual companion. Ask about Bible passages, theology, Christian faith, worship, or anything related to New Life Community Church.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade800,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
