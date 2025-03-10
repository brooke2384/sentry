import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sentry/profile_page.dart';
import 'package:sentry/settings_page.dart';
import 'arrival_screen.dart'; // Ensure this import path is correct

class OnTheWayScreen extends StatefulWidget {
  const OnTheWayScreen({super.key});

  @override
  _OnTheWayScreenState createState() => _OnTheWayScreenState();
}

class _OnTheWayScreenState extends State<OnTheWayScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late GoogleMapController mapController;
  Location location = Location();
  LatLng? markerPosition;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEDF2F1),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We\'re Headed',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF05403C),
                    ),
                  ),
                  Text(
                    'Your Way',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF05403C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE6E5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Time',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black54),
                            ),
                            Text(
                              '15 - 20 min',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your current location',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black54),
                            ),
                            Text(
                              'Mageta Rd, Westlands',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                ),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    if (markerPosition != null) {
                      mapController
                          .moveCamera(CameraUpdate.newLatLng(markerPosition!));
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
              const SizedBox(height: 40.0),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF05403C),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArrivalScreen()),
                    );
                  },
                  child: const Text(
                    'Confirm Location',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
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
}
