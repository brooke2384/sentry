import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  String _username = 'Admin';
  List<Map<String, dynamic>> distressRequests = [];
  List<bool> _isActiveList = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchDistressRequests();
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            if (_mapController == null) {
              _mapController = controller;
              _getUserLocation();
            }
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 15,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: true,
        ),
      ),
    );
  }

  Future<void> _getUserLocation() async {
    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) return;
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) return;
      }

      final loc = await location.getLocation();
      if (mounted) {
      }

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(loc.latitude!, loc.longitude!),
          15,
        ),
      );
    } catch (e) {
      _showSnackBar('Error getting location: $e', isError: true);
    }
  }

  Future<void> _fetchUserData() async {
    if (mounted) {
      setState(() {
        _username = 'Admin';
      });
    }
  }

  Future<void> _fetchDistressRequests() async {
    try {
      final response = await http.get(
          Uri.parse('https://sentry.frobyte.ke/api/v1/alert-request-trails/'));

      if (response.statusCode == 200) {
        List<dynamic> requestData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            distressRequests = requestData.cast<Map<String, dynamic>>();
            _isActiveList = List.filled(distressRequests.length, false);
          });
        }
      } else {
        _showSnackBar('Failed to load distress requests', isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to load distress requests: $e', isError: true);
    }
  }

  Future<void> _notifyUser(String requestId, int index) async {
    try {
      final response = await http.post(
        Uri.parse('https://sentry.frobyte.ke/api/v1/user'),
        body: json.encode({'requestId': requestId}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _isActiveList[index] = true;
          });
        }
        _showSnackBar('User notified successfully');
      } else {
        _showSnackBar('Failed to notify user', isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to notify user: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? SentryTheme.alertRed : SentryTheme.alertGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode
          ? SentryTheme.darkBackground
          : SentryTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? SentryTheme.darkBackground
            : SentryTheme.primaryUltraviolet,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDistressRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $_username',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? SentryTheme.darkTextPrimary
                      : SentryTheme.primaryUltraviolet,
                ),
              ),
              const SizedBox(height: 20),
              _buildMap(),
              const SizedBox(height: 20),
              Text(
                'Active Distress Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? SentryTheme.darkTextPrimary
                      : SentryTheme.primaryUltraviolet,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: distressRequests.length,
                itemBuilder: (context, index) {
                  final request = distressRequests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isDarkMode ? SentryTheme.darkSurface : Colors.white,
                    child: ListTile(
                      title: Text(request['clientName']),
                      subtitle: Text(request['location']),
                      trailing: ElevatedButton(
                        onPressed: _isActiveList[index]
                            ? null
                            : () => _notifyUser(request['id'] ?? '', index),
                        child: Text(_isActiveList[index] ? 'Accepted' : 'Accept'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
