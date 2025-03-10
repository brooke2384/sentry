// screens/success_screen.dart
import 'package:flutter/material.dart';
import 'package:sentry/responda_home.dart';

class RespondaSuccess extends StatelessWidget {
  const RespondaSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D), // Consistent app bar color
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align logo to the right
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Image.asset(
                    'assets/images/logos/Responda.png', // Update with your logo path
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
                    fontFamily: 'hk-grotesk', // Update with your font if needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Reuse the rounded bottom container for the texts
          Container(
            width: double.infinity,
            height: 150, // Adjust height as needed
            decoration: const BoxDecoration(
              color: Color(0xFF06413D), // Same color as app bar
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
                    'Admin Verification Successful!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8), // Slight space between the texts
                  Text(
                    'You can now proceed to the next step.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 120),
          // Success Checkmark Icon
          const Icon(
            Icons.check_circle,
            size: 260,
            color: Color(0xFFD0DB27),
          ),
          const SizedBox(height: 140),
          // Next Button
          ElevatedButton(
            onPressed: () {
              // Navigate to the next screen or home page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const RespondaHomeScreen(), // Replace with actual screen
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFD0DB27), // Updated background color
              padding:
                  const EdgeInsets.symmetric(horizontal: 140, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'NEXT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF06413D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
