import 'package:flutter/material.dart';
import 'package:location/location.dart'; // Import location package
import 'package:permission_handler/permission_handler.dart'
    as perm; // Import permission handler
import 'location_screen.dart'; // Ensure this is imported or adjust as per your directory structure
import 'history_screen.dart'; // Import for history
import 'profile_page.dart'; // Ensure you have this page defined
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps Flutter package
import 'package:http/http.dart' as https; // Import HTTP package for API calls
import 'dart:convert'; // To parse JSON
import 'package:shared_preferences/shared_preferences.dart'; // For storing user session

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool distressSent = false; // Track whether distress call is sent
  bool longPressInProgress = false; // Track if the long press is in progress

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add GlobalKey for Scaffold
  GoogleMapController? _mapController; // Controller for Google Map
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _userLocation;
  String _username = 'User'; // Default value for username
  String _profileImageUrl = 'assets/icons/user.png'; // Default profile image
  String? _userid;

  @override
  void initState() {
    super.initState();
    _setUserData(); // Fetch username and profile image when the widget is created
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

  // Function to fetch user data from custom API
  Future<void> _setUserData() async {
    try {
      print("Here");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userdata = prefs.getString('userDetails');

      if (userdata != null) {
        // Decode the JSON string to get the user details
        Map<String, dynamic> userDetails = json.decode(userdata);

        // Extract the username and profile image URL from the user details
        _userid = userDetails['id'];
        _username =
            userDetails['username']; // Adjust key based on your API response
        _profileImageUrl =
            userDetails['image']; // Adjust key based on your API response
      } else {
        // Handle the case where user data is not available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found. Please login again')),
        );
      }
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // var userdata = prefs.getString('userDetails');
      // _username = json.decode(userdata)[0]['username'];
      // _profileImageUrl =
      // print(token);

      // final response = await http.get(
      //   Uri.parse('https://responda.frobyte.ke/api/v1/users/'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //   },
      // );
      // print(response.body);
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   setState(() {
      //     _username = data[0]['username'] ?? 'User';
      //     _profileImageUrl = data[0]['image'] ?? 'assets/icons/user.png';
      //   });
      // } else {
      //   throw Exception('Failed to load user data');
      // }
    } catch (e) {
      print("Error setting user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  // Function to handle distress call
  Future<void> _sendDistressSignal() async {
    await _getUserLocation(); // Get user's current location

    if (_userLocation != null) {
      try {
        // Get user token from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('authToken');

        var userdata = prefs.getString('userDetails');

        if (userdata != null) {
          // Decode the JSON string to get the user details
          Map<String, dynamic> userDetails = json.decode(userdata);
          print(userDetails['id']);

          // Prepare distress data
          final distressData = {
            'requester': userDetails['id'],
            'status': 'Active',
            'report_description':
                "Alert from $_username", // Date and time combined
          };

          // Send distress signal to the server
          final response = await https.post(
            Uri.parse(
                'https://responda.frobyte.ke/api/v1/alert-requests/'), // API endpoint
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Bearer $token', // Add user token for authorization
            },
            body: json.encode(distressData), // Send distress data as JSON
          );

          print(response);
          print(response.statusCode);
          print(response.body);
          // Handle response
          if (response.statusCode == 200 || response.statusCode == 201) {
            print("Distress signal sent!");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Distress signal sent!')),
            );
          } else {
            throw Exception('Error sending distress signal');
          }
        }
      } catch (e) {
        // Error handling
        print("Error sending distress signal: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending distress signal: $e')),
        );
      }
    } else {
      // Handle case where location data is not available
      print("Location data not available.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location data not available')),
      );
    }
  }

  // Function to handle user logout
  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken'); // Remove token or other session data

      // Navigate to the login screen and clear all previous routes
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for screen size adjustment
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[800]),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Open Drawer using Scaffold key
          },
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to the HistoryScreen when "History" is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()),
                  );
                },
                child: Text(
                  'History',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                // backgroundImage: NetworkImage('https://responda.frobyte.ke/${_profileImageUrl}'),
                backgroundImage:
                    AssetImage('assets/icons/user.png') as ImageProvider,
                radius: 20,
              ),
              const SizedBox(width: 10),
            ],
          )
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
              onTap: _logout, // Use the custom API logout function
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
              'Hello, $_username', // Display the username from the custom API
              style: TextStyle(
                fontSize: 18,
                color: Colors.teal[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Google Map showing user's current location
            Container(
              height: 300,
              width: double.infinity,
              child: _buildMap(),
            ),
            const SizedBox(height: 15),

            // Emergency Help Button aligned with map
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[900],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(screenWidth * 0.9,
                      0), // Adjusts width based on screen size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Emergency help functionality here
                },
                child: const Text(
                  'Need Emergency Help?',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Current Location and Add Address Buttons aligned
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await _getUserLocation(); // Call to get user location
                      if (_userLocation != null) {
                        // Navigate to LocationScreen after fetching the user's location
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationScreen(
                              userLocation: _userLocation!,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.location_on, color: Colors.teal[900]),
                    label: Text('Current Location',
                        style: TextStyle(color: Colors.teal[900])),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to add address screen (adjust route as necessary)
                      Navigator.pushNamed(context, '/add-address');
                    },
                    icon: Icon(Icons.add, color: Colors.teal[900]),
                    label: Text('Add Address',
                        style: TextStyle(color: Colors.teal[900])),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),

            // Animated HELP Button for long press
            Center(
              child: GestureDetector(
                onLongPressStart: (_) {
                  setState(() {
                    longPressInProgress = true;
                  });
                },
                onLongPressEnd: (_) async {
                  setState(() {
                    longPressInProgress = false;
                    distressSent = true; // Simulate sending distress call
                  });

                  // Send distress signal
                  await _sendDistressSignal();

                  // Reset HELP button after 3 seconds
                  Future.delayed(const Duration(seconds: 3), () {
                    setState(() {
                      distressSent = false; // Reset HELP button
                    });
                  });
                },
                child: TweenAnimationBuilder(
                  tween: Tween<double>(
                      begin: 1.0, end: longPressInProgress ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: distressSent
                          ? Colors.green
                          : Colors.red[700], // Green after distress call sent
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          spreadRadius: 4,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        distressSent ? Icons.check : Icons.warning,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
                height: 50), // Space between the button and instructions
            Center(
              child: Text(
                'Press and hold the HELP button to send a distress call.',
                style: TextStyle(fontSize: 14, color: Colors.teal[900]),
                textAlign: TextAlign.center, // Center align the text
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
