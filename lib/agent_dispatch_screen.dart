import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:response/api_service.dart';
import 'package:response/profile_page.dart';
import 'package:response/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentDispatchedPage extends StatelessWidget {
  const AgentDispatchedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true, // Extend the body behind BottomAppBar
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
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
                  'Admin',
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF05403C), Color(0xFFC9D527)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(
                    height: 100), // Spacing between the AppBar and logo
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
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'As you speak\n'
                      'with our call\n'
                      'agents, the\n'
                      'Responda team\n'
                      'is on its way!\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/loading.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05403C),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/on_the_way');
                      },
                      child: const Text(
                        'See Responda\'s Map',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel Request',
                        style: TextStyle(
                          color: Color(0xFF05403C),
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 20), // Add space before the BottomAppBar
                  ],
                ),
              ],
            ),
          ),
        ),
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
                // await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs
                    .remove('authToken'); // Remove token or other session data

                // Navigate to the login screen and clear all previous routes
                Navigator.of(context).pushReplacementNamed('/login');
                // Navigator.pushReplacementNamed(
                //     context, '/login'); // Redirect to login screen after logout
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent, // Fully transparent BottomAppBar
        elevation: 0, // Remove shadow/elevation
        child: SizedBox(
          height: 48, // Height of BottomAppBar
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Align items to far left and right
            children: [
              IconButton(
                icon: Image.asset(
                  'assets/icons/Chat.png',
                  width: 24,
                  height: 24,
                  color: Colors
                      .black, // Ensure the icon color blends with the body gradient
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/chat');
                },
              ),
              IconButton(
                icon: Image.asset(
                  'assets/icons/Home.png',
                  width: 24,
                  height: 24,
                  color: Colors
                      .black, // Ensure the icon color blends with the body gradient
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
}
