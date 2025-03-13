import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sentry/theme/sentry_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = 'User'; // Placeholder username
  String _profileImageUrl = 'assets/icons/user.png'; // Default profile image

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch data from the API
  }

  // Fetching profile details from the custom API
  Future<void> _fetchUserData() async {
    try {
      final sentry = await http.get(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/users/'),
      );

      if (sentry.statusCode == 200) {
        final data = jsonDecode(sentry.body);
        setState(() {
          _username = data['username'] ?? 'User'; // Extract username
          _profileImageUrl =
              data['image'] ?? _profileImageUrl; // Extract profile image
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SentryTheme.primaryUltraviolet, // Dark green
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Navigate to the previous page
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            UserCard(username: _username, profileImageUrl: _profileImageUrl),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SentryTheme.primaryUltraviolet,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildListTile(context, 'Personal and Account Info',
                      '/personal_account_info'),
                  buildListTile(context, 'Privacy', '/privacy'),
                  const Divider(),
                  const Text(
                    'Key Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SentryTheme.primaryUltraviolet,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildListTile(context, 'Medical Profile', '/medical_profile'),
                  buildListTile(
                      context, 'Emergency Contacts', '/emergency_contacts'),
                  buildListTile(
                      context, 'Residential Address', '/residential_address'),
                ],
              ),
            ),
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
                  Navigator.pushNamed(context, '/chat');
                },
              ),
              IconButton(
                icon: Image.asset(
                  'assets/icons/Home.png',
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

  Widget buildListTile(BuildContext context, String title, String route) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: SentryTheme.primaryUltraviolet,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: SentryTheme.primaryUltraviolet,
        ),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String username;
  final String profileImageUrl;

  const UserCard(
      {super.key, required this.username, required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: profileImageUrl.startsWith('http')
                ? NetworkImage(profileImageUrl)
                : AssetImage(profileImageUrl) as ImageProvider,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  color: SentryTheme.primaryUltraviolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'New Account User',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

