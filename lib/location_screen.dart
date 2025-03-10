import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sentry/profile_page.dart';
import 'package:sentry/responda_profile.dart';
import 'package:sentry/responda_settings.dart';
import 'package:sentry/settings_page.dart';

class LocationScreen extends StatefulWidget {
  final LocationData? userLocation;

  const LocationScreen({super.key, this.userLocation});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  Location location = Location();
  LatLng? markerPosition; // To hold the position of the marker
  String _username = 'Admin';
  late String _profileImageUrl = 'assets/icons/user.png';

  // Add a GlobalKey to control the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getCurrentLocation(); // Fetch the current location when the screen initializes
  }

  Future<void> _getCurrentLocation() async {
    // Request location permissions and fetch location data
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData currentLocation = await location.getLocation();
    setState(() {
      markerPosition = LatLng(
          currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0);
      if (markerPosition != null) {
        mapController.moveCamera(CameraUpdate.newLatLng(markerPosition!));
      }
    });
  }

  // Method to upload distress request to Firebase
  Future<void> _uploadDistressRequest() async {
    if (markerPosition != null) {
      await FirebaseFirestore.instance.collection('distressRequests').add({
        'latitude': markerPosition!.latitude,
        'longitude': markerPosition!.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // You can add more fields if needed
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          _username = userDoc['username'] ?? 'Admin';
          _profileImageUrl = userDoc['profileImageUrl'] ?? _profileImageUrl;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[800]),
          onPressed: () {
            _scaffoldKey.currentState!
                .openDrawer(); // Use the GlobalKey to open the drawer
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
                  _username,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Our teams are on standby',
                    style: TextStyle(
                      color: Color(0xFF06413D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Google Map
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: double.infinity,
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        if (markerPosition != null) {
                          mapController.moveCamera(
                              CameraUpdate.newLatLng(markerPosition!));
                        }
                      },
                      initialCameraPosition: CameraPosition(
                        target: markerPosition ?? LatLng(0, 0),
                        zoom: 14,
                      ),
                      markers: markerPosition != null
                          ? {
                              Marker(
                                markerId: const MarkerId('userLocation'),
                                position: markerPosition!,
                                draggable: true,
                                onDragEnd: (newPosition) {
                                  setState(() {
                                    markerPosition = newPosition;
                                  });
                                },
                              ),
                            }
                          : {},
                      onTap: (LatLng position) {
                        setState(() {
                          markerPosition = position;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display user's current location
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.teal, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your current location',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                markerPosition != null
                                    ? 'Lat: ${markerPosition!.latitude}, Lng: ${markerPosition!.longitude}'
                                    : 'Location not available',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF06413D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _uploadDistressRequest(); // Call the function to upload the distress request

                  // Immediately navigate to the next page
                  Navigator.pushNamed(context, '/agent_dispatched');
                },
                child: const Text(
                  'Confirm Location',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
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
