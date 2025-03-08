import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicalProfilePage extends StatefulWidget {
  const MedicalProfilePage({super.key});

  @override
  State<MedicalProfilePage> createState() => _MedicalProfilePageState();
}

class _MedicalProfilePageState extends State<MedicalProfilePage> {
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();

  bool _isEditing = false; // For toggling edit mode

  @override
  void initState() {
    super.initState();
    _fetchMedicalData(); // Fetch data when the page loads
  }

  // Function to fetch medical data from custom API
  Future<void> _fetchMedicalData() async {
    try {
      final response = await http.get(Uri.parse('https://responda.frobyte.ke/api/v1/profiles/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _allergiesController.text = data['allergy_type'] ?? '';
          _medicationsController.text = data['maintenance_medicine_type'] ?? '';
          _bloodTypeController.text = data['blood_type'] ?? '';
        });
      } else {
        throw Exception('Failed to load medical data');
      }
    } catch (e) {
      print('Error fetching medical data: $e');
    }
  }

  // Function to update medical data using custom API
  Future<void> _updateMedicalData() async {
    try {
      final response = await http.put(
        Uri.parse('https://your-api-endpoint.com/api/update-medical-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'allergies': _allergiesController.text,
          'medications': _medicationsController.text,
          'blood_type': _bloodTypeController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false; // Exit edit mode after saving
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical information updated successfully!')),
        );
      } else {
        throw Exception('Failed to update medical data');
      }
    } catch (e) {
      print('Error updating medical data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D), // Dark green
        title: const Text(
          'Medical Profile',
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
              'Your Medical Information',
              style: TextStyle(
                color: Color(0xFF06413D), // Dark green
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Allergies Section (Editable)
            const Text(
              'Allergies:',
              style: TextStyle(
                color: Color(0xFF06413D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _allergiesController,
              enabled: _isEditing, // Enable/disable based on edit mode
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: !_isEditing,
                fillColor: _isEditing ? null : Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),

            // Medications Section (Editable)
            const Text(
              'Current Medications:',
              style: TextStyle(
                color: Color(0xFF06413D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _medicationsController,
              enabled: _isEditing,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: !_isEditing,
                fillColor: _isEditing ? null : Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),

            // Blood Type Section (Editable)
            const Text(
              'Blood Type:',
              style: TextStyle(
                color: Color(0xFF06413D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bloodTypeController,
              enabled: _isEditing,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                    _updateMedicalData(); // Save data to custom API
                  } else {
                    setState(() {
                      _isEditing = true; // Enter edit mode
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32CD32), // Lime green color
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Border radius of 8
                  ),
                ),
                child: Text(_isEditing ? 'Save Medical Information' : 'Edit Medical Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
