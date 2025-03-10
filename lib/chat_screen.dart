import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    // Default admin message
    {
      'text': 'Welcome to Responda, chat with me anytime.',
      'isAdmin': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Fetch messages when the screen loads
  }

  // API call to send a message
  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isAdmin': false, // User message
        });
      });

      try {
        var sentry = await http.post(
          Uri.parse(
              'https://responda.frobyte.ke/api/v1/user'), // Replace with your API endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': _messageController.text,
            'userId': '1', // Replace with the actual user ID
            'isAdmin': false
          }),
        );

        if (sentry.statusCode == 200) {
          // Message successfully sent
        } else {
          // Handle error
          print('Failed to send message: ${sentry.statusCode}');
        }
      } catch (e) {
        print('Error sending message: $e');
      }

      _messageController.clear();
    }
  }

  // API call to fetch messages
  Future<void> _fetchMessages() async {
    try {
      var sentry = await http.get(
        Uri.parse(
            'https://responda.frobyte.ke/api/v1/user?userId=1'), // Replace with your API endpoint
      );

      if (sentry.statusCode == 200) {
        List<dynamic> fetchedMessages = jsonDecode(sentry.body);
        setState(() {
          _messages.addAll(fetchedMessages.map((message) => {
                'text': message['text'],
                'isAdmin': message['isAdmin'],
              }));
        });
      } else {
        print('Failed to fetch messages: ${sentry.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFEFF8F3),
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message['isAdmin']
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message['isAdmin']
                            ? const Color(0xFF06413D)
                            : const Color(0xFFD0DB27),
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
                              : const Color(0xFF06413D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF06413D),
      title: const Text(
        'Chat with Admin',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFF06413D),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
