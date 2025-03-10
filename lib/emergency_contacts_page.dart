import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  bool _isEditing = false; // Toggle for edit mode
  bool _isLoading = false; // For loading state
  String apiUrl = "https://responda.frobyte.ke/api/v1/profiles/"; // API URL

  @override
  void initState() {
    super.initState();
    _fetchEmergencyContact(); // Fetch data when page loads
  }

  // Function to fetch emergency contact data from the API
  Future<void> _fetchEmergencyContact() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Replace 'YOUR_USER_ID' with the actual user ID if required
      final sentry = await http.get(Uri.parse(apiUrl));

      if (sentry.statusCode == 200) {
        // Successful API sentry
        final data = jsonDecode(sentry.body);

        // Assuming 'data' contains 'name' and 'phone'
        setState(() {
          _contactNameController.text = data['name'] ?? '';
          _contactPhoneController.text = data['phone'] ?? '';
        });
      } else {
        // Handle the error sentry
        throw Exception('Failed to load contact data');
      }
    } catch (e) {
      print('Error fetching emergency contact: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to update emergency contact data using the API
  Future<void> _updateEmergencyContact() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Data to be sent in the request body
      final Map<String, String> updatedContact = {
        'name': _contactNameController.text,
        'phone': _contactPhoneController.text,
      };

      final sentry = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedContact),
      );

      if (sentry.statusCode == 200) {
        // Successful update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Emergency contact updated successfully!')),
        );

        setState(() {
          _isEditing = false; // Exit edit mode after saving
        });
      } else {
        throw Exception('Failed to update contact');
      }
    } catch (e) {
      print('Error updating emergency contact: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D), // Dark green
        title: const Text(
          'Emergency Contacts',
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
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader if data is loading
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Contact Information',
                    style: TextStyle(
                      color: Color(0xFF06413D), // Dark green
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Name Section (Editable)
                  const Text(
                    'Contact Name:',
                    style: TextStyle(
                      color: Color(0xFF06413D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contactNameController,
                    enabled: _isEditing, // Enable/disable based on edit mode
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: !_isEditing,
                      fillColor: _isEditing ? null : Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Phone Section (Editable)
                  const Text(
                    'Contact Phone Number:',
                    style: TextStyle(
                      color: Color(0xFF06413D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contactPhoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: !_isEditing,
                      fillColor: _isEditing ? null : Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Edit and Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEditing) {
                          _updateEmergencyContact(); // Save data to API
                        } else {
                          setState(() {
                            _isEditing = true; // Enter edit mode
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF32CD32), // Lime green color
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 24.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Border radius of 8
                        ),
                      ),
                      child: Text(_isEditing
                          ? 'Save Emergency Contact'
                          : 'Edit Emergency Contact'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
