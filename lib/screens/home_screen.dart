import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'location_screen.dart';
import 'history_screen.dart';
import 'profile_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/sentry_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool distressSent = false;
  bool longPressInProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _userLocation;
  String _username = 'User';
  String _profileImageUrl = 'assets/icons/user.png';
  String? _userid;

  @override
  void initState() {
    super.initState();
    _setUserData();
  }

  Future<void> _getUserLocation() async {
    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          throw Exception('Location services are disabled');
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          throw Exception('Location permission not granted');
        }
      }

      _userLocation = await location.getLocation();
      if (_mapController != null && _userLocation != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(
          LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    }
  }

  Future<void> _setUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userdata = prefs.getString('userDetails');

      if (userdata != null) {
        Map<String, dynamic> userDetails = json.decode(userdata);
        setState(() {
          _userid = userDetails['id'];
          _username = userDetails['username'];
          _profileImageUrl = userDetails['image'];
        });
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    }
  }

  Future<void> _sendDistressSignal() async {
    try {
      await _getUserLocation();

      if (_userLocation == null) {
        throw Exception('Location data not available');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      var userdata = prefs.getString('userDetails');

      if (userdata == null || token == null) {
        throw Exception('User authentication data not found');
      }

      Map<String, dynamic> userDetails = json.decode(userdata);
      final distressData = {
        'requester': userDetails['id'],
        'status': 'Active',
        'report_description': "Alert from $_username",
      };

      final response = await http.post(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/alert-requests/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(distressData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Error sending distress signal: ${response.statusCode}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Distress signal sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out: $e')),
        );
      }
    }
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _getUserLocation();
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(0, 0),
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(Icons.menu,
              color:
                  isDarkMode ? SentryTheme.darkTextPrimary : Colors.grey[800]),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () {
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
                    color: isDarkMode
                        ? SentryTheme.darkTextPrimary
                        : Colors.teal[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundImage: AssetImage(_profileImageUrl),
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
                color: isDarkMode ? SentryTheme.darkSurface : Colors.teal[900],
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color:
                      isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person,
                  color: isDarkMode ? SentryTheme.darkTextPrimary : null),
              title: Text('PROFILE',
                  style: TextStyle(
                      color: isDarkMode ? SentryTheme.darkTextPrimary : null)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout,
                  color: isDarkMode ? SentryTheme.darkTextPrimary : null),
              title: Text('LOGOUT',
                  style: TextStyle(
                      color: isDarkMode ? SentryTheme.darkTextPrimary : null)),
              onTap: _logout,
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
                color:
                    isDarkMode ? SentryTheme.darkTextPrimary : Colors.teal[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: _buildMap(),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDarkMode ? SentryTheme.darkSurface : Colors.teal[900],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(screenWidth * 0.9, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Need Emergency Help?',
                  style: TextStyle(
                    fontSize: 15,
                    color:
                        isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? SentryTheme.darkSurface
                          : Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await _getUserLocation();
                      if (_userLocation != null && mounted) {
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
                    icon: Icon(Icons.location_on,
                        color: isDarkMode
                            ? SentryTheme.darkTextPrimary
                            : Colors.teal[900]),
                    label: Text('Current Location',
                        style: TextStyle(
                            color: isDarkMode
                                ? SentryTheme.darkTextPrimary
                                : Colors.teal[900])),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? SentryTheme.darkSurface
                          : Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-address');
                    },
                    icon: Icon(Icons.add,
                        color: isDarkMode
                            ? SentryTheme.darkTextPrimary
                            : Colors.teal[900]),
                    label: Text('Add Address',
                        style: TextStyle(
                            color: isDarkMode
                                ? SentryTheme.darkTextPrimary
                                : Colors.teal[900])),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
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
                    distressSent = true;
                  });

                  await _sendDistressSignal();

                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        distressSent = false;
                      });
                    }
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
                      color: distressSent ? Colors.green : Colors.red[700],
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
                        size: 40,
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
