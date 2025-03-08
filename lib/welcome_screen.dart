import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CustomHamburgerIcon(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF06413D)),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0, // Start below the AppBar
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/welcome.jpg',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.55, // Cover half the height of the welcomeScreen image
            ),
          ),
          Positioned(
            top: 0, // Start right below the AppBar
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/welcomeScreen.png', // Overlay image
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.70, // Cover 3 quarters of the screen height
            ),
          ),
          Positioned(
            top: kToolbarHeight + 20, // Position slightly below the AppBar
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 63.0), // Adjust this padding for horizontal position
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logos/Responda.png', // Logo image
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Responda',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'hk-grotesk',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: kToolbarHeight + 400, // Adjust positioning to appear below the logo
            left: 63, // Align with logo's left padding
            right: 16, // Keep some padding from the right edge
            child: Text(
              'Welcome to Responda RapidDispatch',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'hk-grotesk',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0DB27),
                      padding: const EdgeInsets.symmetric(horizontal: 62, vertical: 15),
                    ),
                    child: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF06413D),
                        fontFamily: 'hk-grotesk',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Hamburger Icon Widget
class CustomHamburgerIcon extends StatelessWidget {
  const CustomHamburgerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24, // Top bar width
          height: 3,
          color: Colors.white,
        ),
        const SizedBox(height: 4), // Spacing between bars
        Container(
          width: 16, // Bottom bar width
          height: 3,
          color: Colors.white,
        ),
      ],
    );
  }
}
