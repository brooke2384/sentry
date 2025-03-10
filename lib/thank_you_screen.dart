import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sentry/profile_page.dart';

class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({super.key});

  @override
  _ThankYouScreenState createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  // Create a GlobalKey for Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedEmojiIndex;
  int? _animatingEmojiIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 50,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
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
                child: const Text(
                  'User',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF06413D), Color(0xFFCEDA2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logos/Responda.png',
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Responda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Thank\n',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'You',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate our Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      IconData iconData;
                      switch (index) {
                        case 0:
                          iconData = Icons.sentiment_very_dissatisfied;
                          break;
                        case 1:
                          iconData = Icons.sentiment_dissatisfied;
                          break;
                        case 2:
                          iconData = Icons.sentiment_neutral;
                          break;
                        case 3:
                          iconData = Icons.sentiment_satisfied;
                          break;
                        case 4:
                          iconData = Icons.sentiment_very_satisfied;
                          break;
                        default:
                          iconData = Icons.sentiment_neutral;
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEmojiIndex =
                                index; // Update the selected index
                            _animatingEmojiIndex = index; // Start animation
                          });

                          // Reset animation but keep background color after a delay
                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              _animatingEmojiIndex =
                                  null; // Reset to default size
                            });
                          });
                        },
                        child: AnimatedScale(
                          scale: _animatingEmojiIndex == index
                              ? 1.5
                              : 1.0, // Scale animation only for active emoji
                          duration: const Duration(
                              milliseconds: 300), // Animation duration
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _selectedEmojiIndex == index
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors
                                      .transparent, // Maintain background color for selected emoji
                              border:
                                  Border.all(color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              iconData,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF06413D),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF06413D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.home, color: Colors.lightGreenAccent),
                  label: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
