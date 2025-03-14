import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String confirmPassword = '';
  String phoneNumber = '';
  String errorMessage = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _signUpWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Store auth token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', userCredential.user!.uid);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign Up Successful!'))
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during sign up.';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email address is already in use.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
      }
      setState(() => errorMessage = message);
      _showErrorDialog(message);
    } catch (e) {
      setState(() => errorMessage = 'An unexpected error occurred.');
      _showErrorDialog('An unexpected error occurred. Please try again.');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Store auth token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', userCredential.user!.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in with Google!'))
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => errorMessage = 'Google sign-in failed');
      _showErrorDialog('Google sign-in failed. Please try again.');
    }
    setState(() => _isLoading = false);
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
                'Sign Up Failed',
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

  Widget _buildSocialButton(IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15),
      ),
      onPressed: onPressed,
      child: FaIcon(icon, color: Colors.white, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Image.asset(
                        'assets/images/sentry.png',
                        height: 80,
                        width: 80,
                      ),
                    ),
                    
                    // Title
                    Text(
                      'Sign Up', 
                      style: TextStyle(
                        color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                        fontSize: 28, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 30),
                    
                    // Email field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: isDarkMode ? SentryTheme.darkTextSecondary : SentryTheme.lightTextSecondary
                        ),
                        filled: true,
                        fillColor: isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() => email = value.trim()),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: isDarkMode ? SentryTheme.darkTextSecondary : SentryTheme.lightTextSecondary
                        ),
                        filled: true,
                        fillColor: isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: isDarkMode ? SentryTheme.darkTextSecondary : SentryTheme.lightTextSecondary,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() => password = value),
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirm Password field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                          color: isDarkMode ? SentryTheme.darkTextSecondary : SentryTheme.lightTextSecondary
                        ),
                        filled: true,
                        fillColor: isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: isDarkMode ? SentryTheme.darkTextSecondary : SentryTheme.lightTextSecondary,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != password) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() => confirmPassword = value),
                    ),
                    const SizedBox(height: 30),
                    
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SentryTheme.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isLoading ? null : _signUpWithEmailPassword,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      'Or sign up with', 
                      style: TextStyle(
                        color: isDarkMode ? SentryTheme.darkTextSecondary : SentryTheme.lightTextSecondary
                      )
                    ),
                    const SizedBox(height: 20),
                    
                    // Social Sign Up Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(FontAwesomeIcons.google, Colors.red, _signUpWithGoogle),
                        const SizedBox(width: 20),
                        _buildSocialButton(FontAwesomeIcons.apple, Colors.black, () {}),
                        const SizedBox(width: 20),
                        _buildSocialButton(Icons.facebook, Colors.blue, () {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          errorMessage, 
                          style: TextStyle(color: SentryTheme.alertRed, fontSize: 14),
                        ),
                      ),
                    
                    // Already have an account? Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: isDarkMode ? SentryTheme.darkTextSecondary : SentryTheme.lightTextSecondary
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: SentryTheme.accentCyan,
                              fontWeight: FontWeight.bold
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
        ),
      ),
    );
  }
}
