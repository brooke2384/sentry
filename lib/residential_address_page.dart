import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding
import 'package:location/location.dart'; // For fetching the current location

class ResidentialAddressPage extends StatefulWidget {
  const ResidentialAddressPage({super.key});

  @override
  State<ResidentialAddressPage> createState() => _ResidentialAddressPageState();
}

class _ResidentialAddressPageState extends State<ResidentialAddressPage> {
  String? _selectedResidence; // For the dropdown selection
  String? _currentLocation; // For displaying the current location
  bool _isEditing = false; // For enabling/disabling editing mode

  final List<String> _countries = [
    "Kenya", "United States", "Canada", "Germany", "France", "Japan", "India",
    // Add all other countries
  ];

  @override
  void initState() {
    super.initState();
    _fetchResidentialInfo(); // Fetch residence info on page load
    _fetchCurrentLocation(); // Fetch current location on page load
  }

  // Fetch residential info from API
  Future<void> _fetchResidentialInfo() async {
    try {
      final response = await http.get(
        Uri.parse('https://responda.frobyte.ke/api/v1/profiles/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Pass your auth token here
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedResidence = data['residence'] ?? 'Select your residence';
        });
      } else {
        print('Error fetching residence info: ${response.body}');
      }
    } catch (e) {
      print('Error fetching residence: $e');
    }
  }

  // Fetch current location using location package
  Future<void> _fetchCurrentLocation() async {
    try {
      Location location = Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();
      setState(() {
        _currentLocation =
        'Lat: ${_locationData.latitude}, Long: ${_locationData.longitude}';
      });
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  // Update residence info via API
  Future<void> _updateResidence() async {
    try {
      final response = await http.patch(
        Uri.parse('https://responda.frobyte.ke/api/v1/profiles/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Pass your auth token here
        },
        body: json.encode({
          'residence': _selectedResidence,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false; // Disable edit mode after saving
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Residence updated successfully!')),
        );
      } else {
        print('Error updating residence: ${response.body}');
      }
    } catch (e) {
      print('Error updating residence: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D), // Dark green
        title: const Text(
          'Residential Address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Residence:',
              style: TextStyle(
                color: Color(0xFF06413D), // Dark green
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Residence Dropdown
            DropdownButtonFormField<String>(
              value: _selectedResidence,
              items: _countries
                  .map((country) => DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              ))
                  .toList(),
              onChanged: _isEditing
                  ? (newValue) {
                setState(() {
                  _selectedResidence = newValue;
                });
              }
                  : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Current Location Display
            const Text(
              'Current Location:',
              style: TextStyle(
                color: Color(0xFF06413D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _currentLocation == null
                ? const CircularProgressIndicator()
                : Text(
              _currentLocation!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Edit/Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_isEditing) {
                    _updateResidence(); // Save residence to API
                  } else {
                    setState(() {
                      _isEditing = true; // Enter edit mode
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32CD32), // Lime green
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Border radius of 8
                  ),
                ),
                child: Text(_isEditing ? 'Save Residence' : 'Edit Residence'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
