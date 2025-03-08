import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'confirmation_page.dart'; // Import Confirmation Page

class InsurancePage extends StatefulWidget {
  const InsurancePage({super.key});

  @override
  _InsurancePageState createState() => _InsurancePageState();
}

class _InsurancePageState extends State<InsurancePage> {
  final _formKey = GlobalKey<FormState>();

  String insuranceName = '';
  String insuranceMemberNo = '';
  String nhifNo = '';
  String doctorName = '';
  String doctorLocation = '';

  // Save insurance details to custom API
  Future<bool> _saveInsuranceDetails() async {
    final url = Uri.parse('https://responda.frobyte.ke/api/v1/profiles/'); // Replace with your actual API endpoint
    final Map<String, dynamic> body = {
      'insurance_name': insuranceName,
      'insurance_member_number': insuranceMemberNo,
      'nhif_number': nhifNo,
      'personal_doctor_name': doctorName,
      'personal_doctor_location': doctorLocation,
      'timestamp': DateTime.now().toIso8601String(), // Current timestamp
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Data saved successfully
        return true; // Indicate success
      } else {
        // Error saving data
        return false; // Indicate failure
      }
    } catch (e) {
      return false; // Indicate failure
    }
  }

  // Proceed to the ConfirmationPage and save the data in the background
  Future<void> _proceedToConfirmation() async {
    if (_formKey.currentState!.validate()) {
      // Try to save insurance details
      bool success = await _saveInsuranceDetails();

      if (success) {
        // Navigate to ConfirmationPage only if saving was successful
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfirmationPage()),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insurance details saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save insurance details. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                width: 450,
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: LinearProgressIndicator(
                    value: 0.8333, // 83.33% progress
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06413D)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 29),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfirmationPage()),
                );
              },
              child: Text(
                "Skip",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Insurance Details",
                      style: TextStyle(
                        fontSize: 26, // Increased size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF08403C), // Updated color
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField('Insurance Name', (value) {
                            insuranceName = value;
                          }),
                          const SizedBox(height: 15),
                          _buildTextField('Insurance Member No', (value) {
                            insuranceMemberNo = value;
                          }),
                          const SizedBox(height: 15),
                          _buildTextField('NHIF No', (value) {
                            nhifNo = value;
                          }),
                          const SizedBox(height: 15),
                          _buildTextField('Personal Doctor Name', (value) {
                            doctorName = value;
                          }),
                          const SizedBox(height: 15),
                          _buildTextField('Personal Doctor Location', (value) {
                            doctorLocation = value;
                          }),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCEDC27), // Background color
                  padding: const EdgeInsets.symmetric(vertical: 12), // Reduced vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                onPressed: _proceedToConfirmation, // Save and navigate to confirmation
                child: const Text(
                  'FINISH',
                  style: TextStyle(
                    fontSize: 16, // Reduced font size
                    color: Color(0xFF08403C), // Text color
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Add some spacing at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
      onChanged: onChanged,
      textAlign: TextAlign.center, // Center the placeholder text
    );
  }
}
