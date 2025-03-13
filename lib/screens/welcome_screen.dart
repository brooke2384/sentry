import 'package:flutter/material.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'package:sentry/screens/sign_up.dart'; // Ensure this is correctly linked

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Large Premium Logo
            Image.asset(
              'assets/images/sentry.png',
              width: 600, // Bigger logo for impact
              height: 600,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // Bold, Catchy SENTRY Text
            Text(
              'SENTRY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42, // Big, bold, and premium
                fontWeight: FontWeight.w900, // Strong visual presence
                letterSpacing: 6, // Adds a sleek effect
                color: isDarkMode
                    ? SentryTheme.darkTextPrimary
                    : SentryTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 15),

            // Subtitle Text - Centered
            Text(
              'Your Personal Safety Guardian',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? SentryTheme.darkTextSecondary
                    : SentryTheme.lightTextSecondary,
              ),
            ),

            const SizedBox(height: 10),

            // Tagline - Slightly Styled for Impact
            Text(
              'Stay Secure, Stay Connected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: isDarkMode
                    ? SentryTheme.darkTextSecondary
                    : SentryTheme.lightTextSecondary,
              ),
            ),

            const SizedBox(height: 40),

            // Get Started Button -> Navigates to Signup Screen
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? SentryTheme.accentBlue
                      : SentryTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
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
