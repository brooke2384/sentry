import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:sentry/theme/sentry_theme.dart';

class ResidentialAddressPage extends StatefulWidget {
  const ResidentialAddressPage({super.key});

  @override
  State<ResidentialAddressPage> createState() => _ResidentialAddressPageState();
}

class _ResidentialAddressPageState extends State<ResidentialAddressPage> {
  String? _selectedResidence;
  String? _currentLocation;
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;
  final Location _location = Location();

  final List<String> _countries = [
    "Kenya", "United States", "Canada", "Germany", "France", "Japan", "India",
    // Add other countries as needed
  ];

  @override
  void initState() {
    super.initState();
    _fetchResidentialInfo();
    _fetchCurrentLocation();
  }

  Future<void> _fetchResidentialInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/profiles/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_AUTH_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedResidence = data['residence'] ?? 'Select your residence';
        });
      } else {
        throw Exception('Failed to fetch residence info: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching residence: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _errorMessage = 'Location services are disabled';
          });
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'Location permission not granted';
          });
          return;
        }
      }

      LocationData locationData = await _location.getLocation();
      setState(() {
        _currentLocation = 'Lat: ${locationData.latitude}, Long: ${locationData.longitude}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching location: $e';
      });
    }
  }

  Future<void> _updateResidence() async {
    if (_selectedResidence == null || _selectedResidence!.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a residence';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.patch(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/profiles/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_AUTH_TOKEN',
        },
        body: json.encode({
          'residence': _selectedResidence,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Residence updated successfully!'),
              backgroundColor: SentryTheme.alertGreen,
            ),
          );
        }
      } else {
        throw Exception('Failed to update residence: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating residence: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
        title: Text(
          'Residential Address',
          style: TextStyle(
            color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(SentryTheme.primaryUltraviolet),
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: SentryTheme.alertRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: SentryTheme.alertRed),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: SentryTheme.alertRed,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    'Current Location',
                    style: TextStyle(
                      color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? SentryTheme.darkSurface : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentLocation ?? 'Fetching location...',
                            style: TextStyle(
                              color: isDarkMode ? SentryTheme.darkTextSecondary : SentryTheme.lightTextSecondary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                          ),
                          onPressed: _fetchCurrentLocation,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Residence',
                    style: TextStyle(
                      color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      filled: true,
                      fillColor: isDarkMode ? SentryTheme.darkSurface : Colors.grey[200],
                      enabled: _isEditing,
                    ),
                    style: TextStyle(
                      color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? SentryTheme.darkSurface : SentryTheme.primaryUltraviolet,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_isEditing) {
                                _updateResidence();
                              } else {
                                setState(() {
                                  _isEditing = true;
                                });
                              }
                            },
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Edit Residence',
                        style: TextStyle(
                          color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

