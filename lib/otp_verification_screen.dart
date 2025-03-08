import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:response/verify_identity_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber; // Accept phone number from previous screen

  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  bool isResending = false;
  bool isResendEnabled = true;
  int resendTimeout = 30;
  Timer? _resendTimer;

  List<String> otp = ["", "", "", ""]; // Store the OTP entered by the user
  String errorMessage = '';

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  // Method to resend OTP
  Future<void> _resendOTP() async {
    setState(() {
      isResending = true;
      isResendEnabled = false;
    });

    final url = Uri.parse('https://responda.frobyte.ke/api/v1/users/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phoneNumber': widget.phoneNumber}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isResending = false;
      });
      _startResendCooldown();
    } else {
      // Handle error (optional)
      setState(() {
        isResending = false;
        errorMessage = 'Failed to resend OTP. Please try again.';
      });
    }
  }

  void _startResendCooldown() {
    resendTimeout = 30;
    setState(() {});

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimeout == 0) {
        timer.cancel();
        setState(() {
          isResendEnabled = true;
        });
      } else {
        setState(() {
          resendTimeout--;
        });
      }
    });
  }

  // Method to verify the OTP entered by the user
  Future<void> _verifyOTP() async {
    String enteredOTP = otp.join(); // Combine the individual OTP boxes

    if (enteredOTP.isNotEmpty) {
      final url = Uri.parse('https://responda.frobyte.ke/api/v1/users/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': widget.phoneNumber,
          'otp': enteredOTP,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success']) {
          // OTP verification successful, navigate to the next screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VerifyIdentityScreen(),
            ),
          );
        } else {
          // Show error message if OTP verification failed
          setState(() {
            errorMessage = jsonResponse['message'] ?? 'Incorrect OTP, please try again.';
          });
        }
      } else {
        // Handle server errors
        setState(() {
          errorMessage = 'Failed to verify OTP. Please try again.';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Please enter the OTP.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D),
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
                    'assets/images/logos/Responda.png',
                    height: 30,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Responda',
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
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF06413D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Verify Your Identity',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the verification code sent to ${widget.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // OTP Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return _buildOTPBox(index);
                }),
              ),
            ),
            const SizedBox(height: 32),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Column(
              children: [
                const Text(
                  'Did not receive the code?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: isResendEnabled ? _resendOTP : null,
                  child: Text(
                    isResending ? 'Resending...' : 'Resend',
                    style: TextStyle(
                      fontSize: 16,
                      color: isResendEnabled ? Colors.lightGreen : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isResendEnabled)
                  Text(
                    'Try again in $resendTimeout seconds',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 300),
                ElevatedButton(
                  onPressed: _verifyOTP, // Call the OTP verification method
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0DB27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 12),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF06413D),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to build OTP input box
  Widget _buildOTPBox(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < otp.length) {
            otp[index] = value;
            if (index < 3) {
              FocusScope.of(context).nextFocus(); // Move to next OTP box
            }
          }
        },
      ),
    );
  }
}
