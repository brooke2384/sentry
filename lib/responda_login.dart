import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:response/responda_home.dart';
import 'package:response/responda_signup.dart';
import 'login_page.dart'; // Import the original login page

class RespondaLogin extends StatefulWidget {
  const RespondaLogin({super.key});

  @override
  _RespondaLoginState createState() => _RespondaLoginState();
}

class _RespondaLoginState extends State<RespondaLogin> {
  final _formKey = GlobalKey<FormState>();
  String emailOrPhone = '';
  String password = '';
  bool isLoading = false;



  Future<void> _loginResponda() async {
    setState(() {
      isLoading = true;
    });

    // Prepare the API endpoint and request body
    const String apiUrl = 'https://responda.frobyte.ke/api/v1/users/';
    Map<String, dynamic> requestBody = {
      'email': emailOrPhone,
      'password': password,
      'role': 1 // Assuming 1 represents the admin role
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
        // If login is successful, navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RespondaHomeScreen()),
        );
      } else if (response.statusCode == 404) {
        // User not found case
        _showUserNotFoundDialog();
      } else {
        _showErrorDialog('Login failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showUserNotFoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'User Not Found',
                style: TextStyle(color: Color(0xFF06413D)),
              ),
            ],
          ),
          content: const Text(
            'The user does not exist. Please sign up first.',
            style: TextStyle(color: Color(0xFF05403C)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFBCCE2A)),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'Login Failed',
                style: TextStyle(color: Color(0xFF06413D)),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFF05403C)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFBCCE2A)),
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
                          'Responda Login',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF06413D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
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
                            hintText: 'Enter email',
                            hintStyle: TextStyle(fontSize: 12.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            emailOrPhone = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email or phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
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
                            hintText: 'Enter password',
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFBCCE2A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: _loginResponda,
                          icon: Image.asset(
                            'assets/icons/google.png', // Add Google logo asset
                            width: 20,
                            height: 20,
                          ),
                          label: const Text(
                            'Sign in with Google',
                            style: TextStyle(
                                color: Color(0xFF05403C),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(

                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _loginResponda();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBCCE2A),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don’t have an account?',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFF05403C),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RespondaSignup()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xFFBCCE2A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
