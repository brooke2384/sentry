import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'package:sentry/screens/profile_page.dart';

class LocationScreen extends StatefulWidget {
  final LocationData? userLocation;

  const LocationScreen({super.key, this.userLocation});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  Location location = Location();
  LatLng? markerPosition;
  String _username = 'User';
  String _profileImageUrl = 'assets/icons/user.png';
  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showErrorDialog('Location services are disabled');
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _showErrorDialog('Location permission is required');
          return;
        }
      }

      LocationData currentLocation = await location.getLocation();
      setState(() {
        markerPosition = LatLng(
            currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0);
      });

      if (markerPosition != null && mounted) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: markerPosition!,
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to get location: $e');
    }
  }

  Future<void> _uploadDistressRequest() async {
    if (markerPosition == null) {
      _showErrorDialog('Unable to determine your location');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await FirebaseFirestore.instance.collection('distressRequests').add({
        'userId': user.uid,
        'latitude': markerPosition!.latitude,
        'longitude': markerPosition!.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'username': _username,
      });

      if (mounted) {
        Navigator.pushNamed(context, '/agent_dispatched');
      }
    } catch (e) {
      _showErrorDialog('Failed to send distress signal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

        if (mounted) {
          setState(() {
            _username = userDoc['username'] ?? 'User';
            _profileImageUrl = userDoc['profileImageUrl'] ?? _profileImageUrl;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor:
              isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
          title: Row(
            children: [
              Icon(Icons.error, color: SentryTheme.alertRed),
              const SizedBox(width: 10),
              Text(
                'Error',
                style: TextStyle(
                  color: isDarkMode
                      ? SentryTheme.darkTextPrimary
                      : SentryTheme.lightTextPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: isDarkMode
                  ? SentryTheme.darkTextSecondary
                  : SentryTheme.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: isDarkMode
                      ? SentryTheme.accentCyan
                      : SentryTheme.primaryPurple,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? SentryTheme.darkSurface
            : SentryTheme.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: isDarkMode
                ? SentryTheme.darkTextPrimary
                : SentryTheme.lightTextPrimary,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  _username,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? SentryTheme.darkTextPrimary
                        : SentryTheme.primaryUltraviolet,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundImage: _profileImageUrl.startsWith('http')
                      ? NetworkImage(_profileImageUrl)
                      : AssetImage(_profileImageUrl) as ImageProvider,
                  radius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: SentryTheme.primaryUltraviolet,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: SentryTheme.darkTextPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: markerPosition ??
                  const LatLng(0, 0), // Default position if location is null
              zoom: 15.0,
            ),
            markers: markerPosition == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId('current_location'),
                      position: markerPosition!,
                    ),
                  },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 32.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              decoration: SentryTheme.emergencyButtonDecoration,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _uploadDistressRequest,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'REQUEST EMERGENCY ASSISTANCE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

