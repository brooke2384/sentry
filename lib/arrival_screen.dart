import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sentry/profile_page.dart';
import 'package:sentry/thank_you_screen.dart';

class ArrivalScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Create a scaffold key

  ArrivalScreen({super.key}); // Remove 'const' keyword from the constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Set the key for the Scaffold
      backgroundColor: const Color(0xFFEDF2F1), // Light background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[800]),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
                child: Text(
                  'User',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundImage: AssetImage('assets/icons/user.png'),
                radius: 20,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal[900],
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('PROFILE'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LOGOUT'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(
                    context, '/login'); // Redirect to login screen after logout
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Team has arrived section combined with rounded bottom corners
          // Team has arrived section combined with rounded bottom corners
          Container(
            height: 190.0, // Increased height
            decoration: const BoxDecoration(
              color: Color(0xFFDDE1E2), // New background color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, bottom: 12.0), // Start lower
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Adjusted alignment
              children: [
                const Spacer(), // Push content to the bottom
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Team',
                            style: TextStyle(
                              fontSize: 35.0, // Increased font size
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Has Arrived',
                            style: TextStyle(
                              fontSize: 35.0, // Increased font size
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.local_hospital_rounded, // Hospital icon
                      size: 40.0,
                      color: Color(0xFF0D4F25), // Green icon
                    ),
                  ],
                ),
                const SizedBox(height: 20.0), // Space below the text
              ],
            ),
          ),

          const SizedBox(height: 20.0),
          // Current location container wrapped in padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(
                    0xFFABC5C9), // Background color for location container
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your current location',
                        style: TextStyle(fontSize: 16.0, color: Colors.black54),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Mageta Rd, Westlands',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.location_pin,
                    size: 30.0,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          // Info containers wrapped in padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: buildInfoContainer('Team Leader', 'Drucilla Shrestha'),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: buildInfoContainer('Responda ID', '4387'),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: buildInfoContainer('Time', '13:36'),
          ),
          const Spacer(),
          // Close request button spans full width
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints.tightFor(width: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF05403C), // Button color
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ThankYouScreen()),
                  );
                },
                child: const Text(
                  'Close Request',
                  style: TextStyle(
                      fontSize: 18.0, color: Colors.white), // White text
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
      // Bottom navigation with bottom app bar
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFEDF2F1),
        elevation: 0,
        child: SizedBox(
          height: 48, // Adjust the height of the bottom bar
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Align items to far left and right
            children: [
              IconButton(
                icon: Image.asset(
                  'assets/icons/Chat.png', // Ensure this path is correct
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/chat');
                },
              ),
              IconButton(
                icon: Image.asset(
                  'assets/icons/Home.png', // Ensure this path is correct
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build the information containers
  Widget buildInfoContainer(String header, String body) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE6E5), // Light greenish color
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            header,
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
