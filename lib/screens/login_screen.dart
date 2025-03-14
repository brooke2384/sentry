import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String emailOrPhone = '';
  String password = '';
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });

        String errorMessage = 'An error occurred during login.';
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          case 'invalid-email':
            errorMessage = 'The email format is incorrect.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many login attempts. Please try again later.';
            break;
        }
        _showErrorDialog(errorMessage);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('An error occurred during login. Please try again.');
      }
    }
  }

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
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', userCredential.user!.uid);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Login with Google failed. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
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
                'Login Failed',
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
                          child: Image.asset(
                            'assets/logo/sentry_logo.svg',
                            height: 80,
                            width: 80,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'Login to Your Account',
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
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email or Phone Number',
                            filled: true,
                            fillColor: isDarkMode
                                ? SentryTheme.darkSurface
                                : SentryTheme.lightSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            color: isDarkMode
                                ? SentryTheme.darkTextPrimary
                                : SentryTheme.lightTextPrimary,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email or phone number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              emailOrPhone = value.trim();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: isDarkMode
                                ? SentryTheme.darkSurface
                                : SentryTheme.lightSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            color: isDarkMode
                                ? SentryTheme.darkTextPrimary
                                : SentryTheme.lightTextPrimary,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _loginUser,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Or continue with',
                      style: TextStyle(
                        color: isDarkMode
                            ? SentryTheme.darkTextSecondary
                            : SentryTheme.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: isLoading ? null : _loginWithGoogle,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDarkMode
                              ? SentryTheme.darkTextSecondary
                              : SentryTheme.lightTextSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/google.png',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Google',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? SentryTheme.darkTextPrimary
                                    : SentryTheme.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
