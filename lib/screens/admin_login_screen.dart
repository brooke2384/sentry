import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sentry/screens/admin_home_screen.dart';
import 'package:sentry/theme/sentry_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String emailOrPhone = '';
  String password = '';
  bool isLoading = false;

  Future<void> _loginAdmin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      const String apiUrl = 'https://sentry.frobyte.ke/api/v1/users/';
      Map<String, dynamic> requestBody = {
        'email': emailOrPhone,
        'password': password,
        'role': 1
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          }
        } else if (response.statusCode == 404) {
          _showErrorDialog('User not found',
              'The user does not exist. Please sign up first.');
        } else {
          _showErrorDialog('Login Failed', 'Login failed. Please try again.');
        }
      } catch (e) {
        _showErrorDialog('Error', 'An error occurred. Please try again.');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: isDarkMode ? SentryTheme.darkSurface : Colors.white,
          title: Row(
            children: [
              Icon(Icons.error, color: SentryTheme.alertRed),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode
                      ? SentryTheme.darkTextPrimary
                      : SentryTheme.primaryUltraviolet,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: isDarkMode
                  ? SentryTheme.darkTextSecondary
                  : SentryTheme.lightTextSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: isDarkMode
                      ? SentryTheme.accentCyan
                      : SentryTheme.primaryUltraviolet,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Sentry Admin Login',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? SentryTheme.darkTextPrimary
                                  : SentryTheme.primaryUltraviolet,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'EMAIL*',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? SentryTheme.darkTextSecondary
                                : SentryTheme.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? SentryTheme.darkSurface
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              color: isDarkMode
                                  ? SentryTheme.darkTextPrimary
                                  : SentryTheme.lightTextPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter email',
                              hintStyle: TextStyle(
                                fontSize: 14.0,
                                color: isDarkMode
                                    ? SentryTheme.darkTextSecondary
                                    : SentryTheme.lightTextSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                emailOrPhone = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'PASSWORD*',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? SentryTheme.darkTextSecondary
                                : SentryTheme.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? SentryTheme.darkSurface
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              color: isDarkMode
                                  ? SentryTheme.darkTextPrimary
                                  : SentryTheme.lightTextPrimary,
                            ),
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Enter password',
                              hintStyle: TextStyle(
                                fontSize: 14.0,
                                color: isDarkMode
                                    ? SentryTheme.darkTextSecondary
                                    : SentryTheme.lightTextSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : _loginAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SentryTheme.accentCyan,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
