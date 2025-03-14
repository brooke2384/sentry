import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sentry/screens/sign_up.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'package:sentry/screens/verify_identity_screen.dart';
import 'otp_verification_screen.dart'; // Import the new screen
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnterMobileScreen extends StatefulWidget {
  const EnterMobileScreen({super.key});

  @override
  _EnterMobileScreenState createState() => _EnterMobileScreenState();
}

class _EnterMobileScreenState extends State<EnterMobileScreen> {
  String selectedCountryCode = '+254'; // Default country code for Kenya
  String selectedCountryFlag = 'KE'; // Default country flag
  String mobileNumber = ''; // Store mobile number
  final _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String errorMessage = '';

  // Custom API: Send OTP to entered mobile number
  Future<void> _verifyMobileNumber() async {
    if (mobileNumber.isNotEmpty) {
      final phoneNumber = '$selectedCountryCode$mobileNumber';

      final url = Uri.parse('https://Sentry.frobyte.ke/api/v1/users/');
      final sentry = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phoneNumber': phoneNumber}),
      );

      if (sentry.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OTPVerificationScreen(phoneNumber: phoneNumber),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Failed to send OTP. Please try again.';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Please enter a mobile number';
      });
    }
  }

  // Google Sign-in method
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // Here you can call your custom API with googleAuth info if needed.

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog(e.toString());
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
                color: SentryTheme.primaryUltraviolet,
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
                  MaterialPageRoute(
                      builder: (context) => const VerifyIdentityScreen()),
                );
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: SentryTheme.primaryUltraviolet,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SentryTheme.primaryUltraviolet,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Image.asset(
                    'assets/images/sentry.png', // Updated path to match pubspec.yaml
                    height: 30,
                    errorBuilder: (context, error, stackTrace) {
                      // Log the error for debugging
                      print('Error loading logo: $error');
                      // Return a placeholder or fallback widget
                      return Container(
                        height: 30,
                        width: 30,
                        color: SentryTheme.accentCyan,
                        child: const Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sentry',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'hk-grotesk',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container with rounded bottom corners
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                color: SentryTheme.primaryUltraviolet,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verify Your Identity',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter your details to continue with verification',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MOBILE NUMBER',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Country Flag + Dropdown Icon (no code)
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IntlPhoneField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            initialCountryCode: selectedCountryFlag,
                            showCountryFlag: true,
                            showDropdownIcon: true,
                            dropdownIconPosition: IconPosition.trailing,
                            disableLengthCheck: true,
                            onCountryChanged: (country) {
                              setState(() {
                                selectedCountryCode = '+${country.dialCode}';
                                selectedCountryFlag = country.code;
                              });
                            },
                            onChanged: (phone) {},
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Mobile Number Input with the country code
                      Flexible(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) {
                              setState(() {
                                mobileNumber = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'MOBILE NUMBER',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Continue Button
                  SizedBox(
                    width: double.infinity, // Make button full-width
                    child: ElevatedButton(
                      onPressed:
                          _verifyMobileNumber, // Trigger OTP verification
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                             SentryTheme.primaryUltraviolet, // Updated background color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 16),

                  // Divider line with "OR" in the middle
                  const Row(
                    children: [
                      Expanded(
                          child: Divider(
                        thickness: 2,
                        color: SentryTheme.primaryUltraviolet,
                      )),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: SentryTheme.primaryUltraviolet,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                        thickness: 2,
                        color: SentryTheme.primaryUltraviolet,
                      )),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // "Continue with Gmail" Button
                  SizedBox(
                    width: double.infinity, // Make button full-width
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _signInWithGoogle(); // Google Sign-up logic
                      },
                      icon: Image.asset(
                        'assets/icons/google.png',
                        height: 24.0,
                        width: 24.0,
                      ),
                      label: const Text(
                        'CONTINUE WITH GMAIL',
                        style: TextStyle(
                          color: SentryTheme.primaryUltraviolet,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // "Continue with E-Mail" Button
                  SizedBox(
                    width: double.infinity, // Make button full-width
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to SuccessScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  SignUpPage(),
                          ),
                        );
                      },
                      label: const Text(
                        'CONTINUE WITH E-MAIL',
                        style: TextStyle(
                          color: SentryTheme.primaryUltraviolet,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Grey background
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Another divider line
                  const Divider(
                    thickness: 2,
                    color: SentryTheme.primaryUltraviolet,
                  ),

                  const SizedBox(height: 16),
                  const Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: TextStyle(fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

