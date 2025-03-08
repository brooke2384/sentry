import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:response/responda_identity.dart';
import 'package:response/responda_login.dart';
import 'package:response/verify_identity_screen.dart';
import 'package:response/login_page.dart';

class RespondaSignup extends StatefulWidget {
  const RespondaSignup({super.key});

  @override
  _RespondaSignupState createState() => _RespondaSignupState();
}

class _RespondaSignupState extends State<RespondaSignup> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String errorMessage = '';

  // Function to show success modal
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFFBCCE2A), // Green color to match theme
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Account Created Successfully!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF06413D), // Dark green text
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBCCE2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RespondaIdentityScreen()),
                );
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Color(0xFF06413D), // Dark green text
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show error modal
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error,
              color: Colors.red, // Red color for error
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              error,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to sign up with email and password using the API
  Future<void> _signUpWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://responda.frobyte.ke/api/v1/user');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'first_name': fullName,
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 201) {
          // Sign-up successful, show success modal
          _showSuccessDialog();
        } else {
          // Handle error response from API
          final responseData = json.decode(response.body);
          _showErrorDialog(responseData['message'] ?? 'Sign-up failed');
        }
      } catch (e) {
        _showErrorDialog('Sign-up failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
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
                      const Center(
                        child: Text(
                          'Create an Admin Account',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF06413D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Full Name Field
                      const Text(
                        'FULL NAME*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05403C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter your full name',
                            hintStyle: TextStyle(fontSize: 12.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            fullName = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      const Text(
                        'EMAIL*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05403C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(fontSize: 12.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            email = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      const Text(
                        'PASSWORD*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05403C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(fontSize: 12.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      const Text(
                        'CONFIRM PASSWORD*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05403C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Confirm your password',
                            hintStyle: TextStyle(fontSize: 12.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            confirmPassword = value;
                          },
                          validator: (value) {
                            if (value != password) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Register Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBCCE2A),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _signUpWithEmailPassword,
                child: const Center(
                  child: Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(
                      color: Color(0xFF05403C),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Login link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Color(0xFF05403C),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RespondaLogin(),
                          ),
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Color(0xFF05403C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
