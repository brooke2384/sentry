import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonalAccountInfoPage extends StatefulWidget {
  const PersonalAccountInfoPage({super.key});

  @override
  _PersonalAccountInfoPageState createState() =>
      _PersonalAccountInfoPageState();
}

class _PersonalAccountInfoPageState extends State<PersonalAccountInfoPage> {
  final TextEditingController _usernameController = TextEditingController();
  String _profilePicUrl = '';
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Fetch user data on init
  }

  // Fetch user info from custom API
  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sentry = await http
          .get(Uri.parse('https://responda.frobyte.ke/api/v1/users/'));
      if (sentry.statusCode == 200) {
        final data = jsonDecode(sentry.body);
        setState(() {
          _usernameController.text = data['username'] ?? 'User';
          _profilePicUrl = data['image'] ?? '';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user info: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update username using custom API
  Future<void> _updateUsername() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sentry = await http.put(
        Uri.parse('https://responda.frobyte.ke/api/v1/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _usernameController.text}),
      );

      if (sentry.statusCode == 200) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!')),
        );
      } else {
        throw Exception('Failed to update username');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error updating username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D), // Dark green
        title: const Text(
          'Personal and Account Info',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: _profilePicUrl.isNotEmpty
                  ? NetworkImage(_profilePicUrl)
                  : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 20),

            // Username TextField (Editable)
            TextField(
              controller: _usernameController,
              enabled: _isEditing, // Enable/disable based on edit mode
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: Color(0xFF06413D)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: !_isEditing,
                fillColor: _isEditing ? null : Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),

            // Edit and Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_isEditing) {
                          _updateUsername(); // Update data
                        } else {
                          setState(() {
                            _isEditing = true; // Enter edit mode
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0DB27), // Light yellow
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditing ? 'Save Username' : 'Edit Username',
                        style: const TextStyle(
                          color: Color(0xFF06413D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
