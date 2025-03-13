import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sentry/theme/sentry_theme.dart'; // Import the Sentry theme

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Fetch messages when the screen loads
  }

  @override
  void dispose() {
    _messageController.dispose(); // Properly dispose the controller
    super.dispose();
  }

  // API call to send a message
  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final messageText = _messageController.text;
      _messageController.clear(); // Clear immediately for better UX
      
      // Optimistically add message to UI
      setState(() {
        _messages.add({
          'text': messageText,
          'isAdmin': true, // Admin message
          'timestamp': DateTime.now().toIso8601String(),
        });
      });

      try {
        var response = await http.post(
          Uri.parse(
              'https://sentry.frobyte.ke/api/v1/user'), // Updated URL to lowercase sentry
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': messageText,
            'adminId': 'admin123', // Replace with actual admin ID
            'isAdmin': true,
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );

        if (response.statusCode != 200) {
          // Handle error - show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Show error in UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // API call to fetch messages
  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      var response = await http.get(
        Uri.parse(
            'https://sentry.frobyte.ke/api/v1/user?adminId=admin123'), // Updated URL
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedMessages = jsonDecode(response.body);
        setState(() {
          _messages.clear(); // Clear existing messages to avoid duplicates
          _messages.addAll(fetchedMessages.map((message) => {
                'text': message['text'] ?? 'No message content',
                'isAdmin': message['isAdmin'] ?? false,
                'timestamp': message['timestamp'] ?? DateTime.now().toIso8601String(),
              }));
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // Show error in UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch messages: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error in UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching messages: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: isDarkMode ? SentryTheme.darkBackground : const Color(0xFFEFF8F3),
              child: _isLoading 
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(
                          color: isDarkMode 
                              ? SentryTheme.darkTextPrimary 
                              : SentryTheme.primaryUltraviolet,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Align(
                          alignment: message['isAdmin']
                              ? Alignment.centerRight
                              : Alignment.centerLeft, // Admin on right, user on left
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: message['isAdmin']
                                  ? SentryTheme.primaryUltraviolet
                                  : SentryTheme.accentCyan,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message['text'],
                              style: TextStyle(
                                color: message['isAdmin']
                                    ? Colors.white
                                    : SentryTheme.primaryUltraviolet,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          _buildMessageInput(isDarkMode),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchMessages,
        backgroundColor: SentryTheme.accentCyan,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: SentryTheme.primaryUltraviolet,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/sentry_logo.png',
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Sentry Chat',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            // Show info dialog about the chat
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'About Sentry Chat',
                  style: TextStyle(color: SentryTheme.primaryUltraviolet),
                ),
                content: const Text(
                  'This is the admin chat interface for Sentry. Use this to communicate with users who need assistance.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: SentryTheme.accentCyan),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageInput(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: isDarkMode ? SentryTheme.darkSurface : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: isDarkMode ? SentryTheme.darkBackground : Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: SentryTheme.primaryUltraviolet,
                  onPressed: () {
                    // Implement file attachment functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File attachment coming soon'),
                      ),
                    );
                  },
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: SentryTheme.accentCyan,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.white,
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

