import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sentry/theme/sentry_theme.dart';

class PersonalAccountInfoPage extends StatefulWidget {
  const PersonalAccountInfoPage({super.key});

  @override
  _PersonalAccountInfoPageState createState() => _PersonalAccountInfoPageState();
}

class _PersonalAccountInfoPageState extends State<PersonalAccountInfoPage> {
  final TextEditingController _usernameController = TextEditingController();
  String _profilePicUrl = '';
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/users/'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _usernameController.text = data['username'] ?? 'User';
          _profilePicUrl = data['image'] ?? '';
        });
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching user info: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    // Implement your auth token retrieval logic here
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_AUTH_TOKEN',
    };
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Username cannot be empty';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.put(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/users/'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({'username': _usernameController.text}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Username updated successfully!'),
              backgroundColor: SentryTheme.alertGreen,
            ),
          );
        }
      } else {
        throw Exception('Failed to update username: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating username: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
        title: Text(
          'Personal and Account Info',
          style: TextStyle(
            color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(SentryTheme.primaryUltraviolet),
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: SentryTheme.alertRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: SentryTheme.alertRed),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: SentryTheme.alertRed,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePicUrl.isNotEmpty
                        ? NetworkImage(_profilePicUrl)
                        : const AssetImage('assets/icons/user.png') as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: !_isEditing,
                      fillColor: isDarkMode ? SentryTheme.darkSurface : Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_isEditing) {
                                _updateUsername();
                              } else {
                                setState(() {
                                  _isEditing = true;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? SentryTheme.darkSurface : SentryTheme.primaryUltraviolet,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Save Username' : 'Edit Username',
                        style: TextStyle(
                          color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
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

