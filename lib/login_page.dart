import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In for Firebase
import 'enter_mobile_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String emailOrPhone = '';
  String password = '';
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Google Sign-In instance

  // Login with Firebase (Email/Password)
  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailOrPhone,
          password: password,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', userCredential.user!.uid);

        // Navigate to HomePage
        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });

        // Handling different FirebaseAuth errors
        if (e.code == 'user-not-found') {
          _showErrorDialog('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          _showErrorDialog('Wrong password provided for that user.');
        } else if (e.code == 'invalid-email') {
          _showErrorDialog('The email format is incorrect.');
        } else if (e.code == 'too-many-requests') {
          _showErrorDialog('Too many login attempts. Please try again later.');
        } else {
          _showErrorDialog('An error occurred during login. Please try again.');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('An error occurred during login. Please try again.');
      }
    }
  }


  // Login with Google
  Future<void> _loginWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', userCredential.user!.uid);

      // Navigate to HomePage
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Login with Google failed. Please try again.');
    }
  }

  // Error dialog to show user-friendly messages
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
                          'Login to Your Account',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF06413D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'EMAIL OR PHONE NUMBER*',
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
                            hintText: 'Enter email or phone number',
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
                            // Regex to check for valid email format if input looks like an email
                            if (value.contains('@') && !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                              return 'Please enter a valid email address';
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const EnterMobileScreen()),
                              );
                            },
                            child: const Text(
                              'Sign up here',
                              style: TextStyle(
                                  color: Color(0xFF06413D),
                                  fontWeight: FontWeight.bold),
                            ),
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
                          onPressed: _loginWithGoogle,
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
                          _loginUser();
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
                            color: Color(0xFF06413D),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Navigate to the Responda login page
                      Navigator.pushReplacementNamed(context,
                          '/responda_login'); // Redirect to home screen
                    },
                    child: const Text(
                      'Are you a responda? Login here',
                      style: TextStyle(
                          color: Color(0xFF05403C),
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
