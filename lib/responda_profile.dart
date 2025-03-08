import 'package:flutter/material.dart';

class RespondaProfile extends StatelessWidget {
  const RespondaProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D), // Dark green
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white, // Ensure icon color matches the theme
          onPressed: () {
            Navigator.pop(context); // Navigate to the previous page
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white, // White text to match the dark green background
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const UserCard(),
            const SizedBox(height: 16),
            buildListTile(context, 'Personal and Account Info', '/personal_account_info'),
            buildListTile(context, 'Privacy', '/privacy'),
            const Divider(),
            buildListTile(context, 'Residential Address', '/residential_address'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white54,
        elevation: 0,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset(
                  'assets/icons/Chat.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/admin_chat');
                },
              ),
              IconButton(
                icon: Image.asset(
                  'assets/icons/Home.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/admin_home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile(BuildContext context, String title, String route) {
    return Card(
      color: const Color(0xFFD0DB27), // Light yellow to match the theme
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF06413D), // Dark green text to match theme
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF06413D), // Dark green arrow icon
        ),
        onTap: () {
          Navigator.pushNamed(context, route); // Navigate to the respective page
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Colors.white, // White background for user card
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/icons/user.png'),
        ),
        title: Text(
          'User',
          style: TextStyle(
            color: Color(0xFF06413D), // Dark green for the user name
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'User account details',
          style: TextStyle(
            color: Colors.black54, // Subtle gray for the subtitle
          ),
        ),
      ),
    );
  }
}
