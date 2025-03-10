import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sentry/profile_page.dart';

// Dummy distress request data
final List<Map<String, String>> distressRequests = [
  {
    'date': '24th July 2024',
    'team': 'HealthCare Ambulance',
    'status': 'Completed',
  },
  {
    'date': '15th August 2024',
    'team': 'City Rescue',
    'status': 'Completed',
  },
  {
    'date': '3rd September 2024',
    'team': 'Emergency Aid Service',
    'status': 'Ongoing',
  },
];

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background for the screen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 8.0), // Adjust padding as needed
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/icons/user.png'),
            radius: 20, // Set a smaller radius for the avatar
          ),
        ),
        title: const Text(
          'Barry Koech',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle:
            false, // Optional: This aligns the title to the left, next to the avatar
        actions: [
          IconButton(
            onPressed: () {
              // Settings action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.black),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Emergency History Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1C40F), // Yellow background
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Emergency History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Last Dispatch: 24th July 2024',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ambulance Team: HealthCare Ambulance',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to distress history page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DistressHistoryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Solutions Corner Section
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C), // Pink background
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Security Gadgets',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Explore latest security gadgets',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to ordering page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderingPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Explore',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B59B6), // Purple background
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Insure Your Assets',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Get insurance coverage',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to assets page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AssetsPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Explore',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Incident Reports Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF95A5A6), // Light grey background
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incident Reports',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Review past incident reports',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to incident reports page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IncidentReportsPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Incident Report',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
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
}

// Distress History Page
class DistressHistoryScreen extends StatelessWidget {
  const DistressHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distress History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('distressRequests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No distress requests found.'));
          }

          final distressRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: distressRequests.length,
            itemBuilder: (context, index) {
              final request = distressRequests[index];
              final timestamp = (request['timestamp'] as Timestamp).toDate();
              final location = request['location'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text('Request ID: ${request['id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Location: Lat ${location['latitude']}, Long ${location['longitude']}'),
                      Text('Time: ${timestamp.toString()}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Ordering Page
class OrderingPage extends StatelessWidget {
  const OrderingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Gadgets'),
        backgroundColor: Colors.redAccent,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: 4, // Dummy products
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/product.jpg', // Dummy image
                    fit: BoxFit.cover,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Security Camera',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Price: \$200'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Purchase action
                  },
                  child: const Text('Purchase'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Assets Page
class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assets'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Text('You have no assets.'),
      ),
    );
  }
}

// Incident Reports Page
class IncidentReportsPage extends StatelessWidget {
  const IncidentReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Reports'),
        backgroundColor: Colors.grey,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Dummy incident reports
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: const Text('Incident: Theft'),
              subtitle: Text(
                  'Reported on: ${DateTime.now().subtract(Duration(days: index * 30))}'),
            ),
          );
        },
      ),
    );
  }
}
