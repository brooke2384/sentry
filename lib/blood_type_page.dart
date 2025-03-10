import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'insurance_page.dart'; // Import the InsurancePage

class BloodTypePage extends StatefulWidget {
  const BloodTypePage({super.key});

  @override
  _BloodTypePageState createState() => _BloodTypePageState();
}

class _BloodTypePageState extends State<BloodTypePage> {
  String? selectedBloodType;
  bool _isLoading = false;

  // Save blood type data to the custom API (in background)
  Future<bool> _saveBloodType() async {
    final url = Uri.parse(
        'https://responda.frobyte.ke/api/v1/profiles/'); // Replace with your API endpoint
    final Map<String, dynamic> body = {
      'blood_type': selectedBloodType ?? 'Unknown',
      'timestamp': DateTime.now().toIso8601String(), // Current timestamp
    };

    try {
      final sentry = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (sentry.statusCode == 200) {
        // Data saved successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        return true; // Indicate success
      } else {
        // Error while saving data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save data.'),
            backgroundColor: Colors.red,
          ),
        );
        return false; // Indicate failure
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save data.'),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Indicate failure
    }
  }

  // Proceed to InsurancePage after saving blood type
  Future<void> _proceedToInsurancePage() async {
    if (selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your blood type before proceeding.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    // Save the blood type and wait for completion
    bool success = await _saveBloodType();

    // Navigate only if data saved successfully
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InsurancePage()),
      );
    }

    // Hide loading indicator
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF06413D)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 29),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InsurancePage()),
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                    color: Color(0xFF06413D), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "What is your blood type?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF05403C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Blood type options
              Column(
                children: [
                  _buildBloodTypeButton('A+'),
                  const SizedBox(height: 20),
                  _buildBloodTypeButton('A-'),
                  const SizedBox(height: 20),
                  _buildBloodTypeButton('B+'),
                  const SizedBox(height: 20),
                  _buildBloodTypeButton('B-'),
                  const SizedBox(height: 20),
                  _buildBloodTypeButton('AB+'),
                  const SizedBox(height: 20),
                  _buildBloodTypeButton('AB-'),
                  const SizedBox(height: 20),
                  _buildBloodTypeButton('O+'),
                  const SizedBox(height: 20),
                  _buildBloodTypeButton('O-'),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBCCE2A),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _proceedToInsurancePage,
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(fontSize: 16, color: Color(0xFF06413D)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build blood type buttons
  Widget _buildBloodTypeButton(String bloodType) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedBloodType = bloodType;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedBloodType == bloodType
            ? const Color(0xFFBCCE2A)
            : Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        bloodType,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
