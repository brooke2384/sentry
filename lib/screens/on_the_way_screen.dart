import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sentry/theme/sentry_theme.dart';

class OnTheWayScreen extends StatefulWidget {
  const OnTheWayScreen({super.key});

  @override
  _OnTheWayScreenState createState() => _OnTheWayScreenState();
}

class _OnTheWayScreenState extends State<OnTheWayScreen> {
  late GoogleMapController mapController;
  Location location = Location();
  LatLng? markerPosition;
  bool _isLoading = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

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
      final newPosition = LatLng(
          currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0);

      setState(() {
        markerPosition = newPosition;
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: newPosition,
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
          Marker(
            markerId: const MarkerId('responder_location'),
            position: LatLng(
                newPosition.latitude + 0.01, newPosition.longitude + 0.01),
            infoWindow: const InfoWindow(title: 'Responder Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        };

        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              newPosition,
              LatLng(newPosition.latitude + 0.01, newPosition.longitude + 0.01),
            ],
            color: SentryTheme.primaryUltraviolet,
            width: 5,
          ),
        };
      });

      if (mounted) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newPosition,
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to get location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      backgroundColor:
          isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
        elevation: 0,
        title: Text(
          'Emergency Response',
          style: TextStyle(
            color: isDarkMode
                ? SentryTheme.darkTextPrimary
                : SentryTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode
                ? SentryTheme.darkTextPrimary
                : SentryTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
