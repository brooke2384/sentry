import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:response/verify_identity_screen.dart';
import 'package:response/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign-in method
  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled sign-in

      // Storing user data locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', googleUser.email);
      await prefs.setString('displayName', googleUser.displayName ?? 'User');
      await prefs.setString('photoURL', googleUser.photoUrl ?? '');

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      // Show error dialog if sign-up fails
      _showErrorDialog('Sign-up failed: ${e.toString()}');
    }
  }

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
              color: Color(0xFFBCCE2A),
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Account Created Successfully!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF06413D),
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
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const VerifyIdentityScreen()),
                );
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Firebase email/password sign-up
  Future<void> _signUpWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Firebase signup
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Optionally, update the user's display name
        await userCredential.user!.updateDisplayName(username);

        // Show success dialog
        _showSuccessDialog();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showErrorDialog('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          _showErrorDialog('The account already exists for that email.');
        } else if (e.code == 'invalid-email') {
          _showErrorDialog('The email provided is invalid.');
        } else {
          _showErrorDialog('Sign-up failed: ${e.message}');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      }
    }
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
              color: Colors.red,
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
                Navigator.pop(context);
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
                          'Create an Account',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF06413D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Username Field
                      const Text(
                        'USERNAME*',
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
                            hintText: 'Enter your username',
                            hintStyle: TextStyle(fontSize: 12.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            username = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your username';
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
                            if (value!.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != password) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Or sign up with',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 12.0),
                          ),
                        ],
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
                          onPressed: _signUpWithGoogle,
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Sign up button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _signUpWithEmailPassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBCCE2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width, 50),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFF06413D), // Dark green text
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Redirect to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Color(0xFF06413D)),
                    ),
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
