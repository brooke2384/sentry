import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:sentry/responda_profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert'; // For json decoding
import 'package:http/http.dart' as http; // For API requests

class RespondaHomeScreen extends StatefulWidget {
  const RespondaHomeScreen({super.key});

  @override
  _RespondaHomeScreenState createState() => _RespondaHomeScreenState();
}

class _RespondaHomeScreenState extends State<RespondaHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _userLocation;
  String _username = 'Admin';
  String _profileImageUrl = 'assets/icons/user.png';

  // List to hold distress request data
  List<Map<String, dynamic>> distressRequests = [
    {
      'clientName': 'John Doe',
      'time': '2 mins ago',
      'location': 'Central Park, NY',
      'date': '2024-10-04',
    },
    {
      'clientName': 'Jane Smith',
      'time': '5 mins ago',
      'location': 'Times Square, NY',
      'date': '2024-10-04',
    },
    {
      'clientName': 'Alice Johnson',
      'time': '10 mins ago',
      'location': 'Brooklyn Bridge, NY',
      'date': '2024-10-04',
    },
    {
      'clientName': 'Michael Brown',
      'time': '15 mins ago',
      'location': 'Statue of Liberty, NY',
      'date': '2024-10-04',
    },
  ];

  // State variable to track active/inactive status for each card
  List<bool> _isActiveList = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchDistressRequests();
    _isActiveList = List<bool>.filled(distressRequests.length, false);
  }

  // Function to create Google Map
  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _getUserLocation(); // Get user location when map is created
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(0, 0), // Default position, will be updated
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  // Function to get user's location
  Future<void> _getUserLocation() async {
    print("Checking if location service is enabled...");
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      print("Location services are disabled. Requesting to enable...");
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("Location service not enabled.");
        return; // Exit if the service is not enabled
      }
    }

    print("Checking for location permissions...");
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      print("Location permission denied. Requesting permission...");
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("Location permission not granted.");
        return; // Exit if permission is not granted
      }
    }

    print("Fetching location...");
    try {
      _userLocation = await location.getLocation();
      print("Location fetched: $_userLocation");
      if (_mapController != null && _userLocation != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(
          LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
        ));
      }
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    }
  }

  Future<void> _fetchUserData() async {
    // Add any necessary API request for user/admin data if required
    setState(() {
      _username = 'Admin';
      _profileImageUrl = 'assets/icons/user.png'; // Use default profile image
    });
  }

  // Fetch distress requests from API
  Future<void> _fetchDistressRequests() async {
    try {
      final sentry = await http.get(Uri.parse(
          'https://responda.frobyte.ke/api/v1/alert-request-trails/'));

      if (sentry.statusCode == 200) {
        List<dynamic> requestData = jsonDecode(sentry.body);
        setState(() {
          distressRequests = requestData.cast<Map<String, dynamic>>();
          _isActiveList = List<bool>.filled(distressRequests.length, false);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load distress requests')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load distress requests')),
      );
    }
  }

  // Notify the user when a request is accepted
  Future<void> _notifyUser(String requestId) async {
    try {
      final sentry = await http.post(
        Uri.parse('https://responda.frobyte.ke/api/v1/user'),
        body: json.encode({'requestId': requestId}),
        headers: {"Content-Type": "application/json"},
      );

      if (sentry.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User notified successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to notify user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to notify user')),
      );
    }
  }

  // Build Active Requests section with dynamic distress requests data
  Widget _buildActiveRequestsSection() {
    if (distressRequests.isEmpty) {
      return Center(
        child: Text(
          'No active Requests',
          style: TextStyle(
            fontSize: 16,
            color: Colors.teal[900],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal[900],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: distressRequests.length,
              itemBuilder: (context, index) {
                final entry = distressRequests[index];
                return Card(
                  color: Colors.grey[200],
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User: ${entry['clientName']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('Location: ${entry['location'] ?? 'Unknown'}'),
                        Text('Date: ${entry['date'] ?? 'Unknown'}'),
                        Text('Time: ${entry['time'] ?? 'Unknown'}'),
                        const SizedBox(height: 10),
                        Text(
                          _isActiveList[index] ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: _isActiveList[index]
                                ? Color(0xFFBCCE2A)
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isActiveList[index]
                                ? Colors.red
                                : Color(0xFFBCCE2A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isActiveList[index] = !_isActiveList[index];
                              if (_isActiveList[index]) {
                                _notifyUser(entry['requestId']);
                              }
                            });
                          },
                          child: Text(
                            _isActiveList[index]
                                ? 'CANCEL REQUEST'
                                : 'ACCEPT REQUEST',
                            style: const TextStyle(
                                color: Color(0xFF06413D),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
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
              CircleAvatar(
                backgroundImage: _profileImageUrl.startsWith('http')
                    ? NetworkImage(_profileImageUrl)
                    : AssetImage(_profileImageUrl) as ImageProvider,
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
                'MENU',
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
                  MaterialPageRoute(
                      builder: (context) => const RespondaProfile()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LOGOUT'),
              onTap: () async {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $_username',
              style: TextStyle(
                fontSize: 18,
                color: Colors.teal[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: _buildMap(),
            ),
            const SizedBox(height: 8),
            _buildActiveRequestsSection(),
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
}
