import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  _MedicinesPageState createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  String? takesMedicines;
  String medicineType = '';
  bool showMedicineField = false;
  bool _isLoading = false;

  // Function to save medicine data to your custom API
  Future<void> _saveMedicineData() async {
    try {
      var url = Uri.parse('https://Sentry.frobyte.ke/api/v1/profiles/');
      var sentry = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'is_taking_maintenance_medicine':
              takesMedicines == 'Yes', // Convert to boolean
          'maintenance_medicine_type':
              medicineType.isEmpty ? 'None' : medicineType,
        }),
      );

      if (sentry.statusCode == 200) {
        print('Data saved successfully');
      } else {
        throw Exception('Failed to save data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle saving medicine info and navigate to next page
  Future<void> _proceedToNextPage() async {
    if (takesMedicines == null ||
        (takesMedicines == 'Yes' && medicineType.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the form before proceeding.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Save to your API in the background
    await _saveMedicineData();

    // Navigate to the next page immediately after saving
    Navigator.pushNamed(context, '/blood_type');

    setState(() {
      _isLoading = false; // Stop loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[200], // Light grey background for the entire page
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back when back button is pressed
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 8, // Height of the progress bar
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  child: LinearProgressIndicator(
                    value: 0.5, // 50% progress
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF05403C)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 29),
            // Skip button
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/blood_type'); // Skip to next page
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                    color: Color(0xFF05403C), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Question Text
                  const Text(
                    "Do you take any maintenance medicines?",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF05403C)), // Updated color
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Yes/No Button Choices
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            takesMedicines = 'Yes';
                            showMedicineField = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: takesMedicines == 'Yes'
                              ? const Color(0xFFBCCE2A)
                              : Colors.grey[300],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12), // Reduced height
                          minimumSize: const Size(double.infinity,
                              55), // Slightly reduced button size
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                          ),
                        ),
                        child: const Text('YES',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16)), // Slightly reduced font
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            takesMedicines = 'No';
                            showMedicineField = false;
                            medicineType =
                                ''; // Clear medicine type if "No" is selected
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: takesMedicines == 'No'
                              ? const Color(0xFFBCCE2A)
                              : Colors.grey[300],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12), // Reduced height
                          minimumSize: const Size(double.infinity,
                              55), // Slightly reduced button size
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                          ),
                        ),
                        child: const Text('NO',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16)), // Slightly reduced font
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (takesMedicines == 'Yes')
                    SizedBox(
                      width: double.infinity, // Full width for the text field
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Type of medicine',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Slight border radius (matches buttons)
                            borderSide: BorderSide.none, // No border outline
                          ),
                        ),
                        style: const TextStyle(
                            color: Color(0xFF05403C)), // Set text color
                        minLines: 6, // Increase input height
                        maxLines: 10, // Allow multiple lines
                        onChanged: (value) {
                          setState(() {
                            medicineType = value;
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 40),
                  // Continue Button (Sticky to the bottom)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 20.0), // Padding for button
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFBCCE2A), // Background color
                          padding: const EdgeInsets.symmetric(
                              vertical: 15), // Reduced padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Slight border radius
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : _proceedToNextPage, // Show loading and proceed
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'CONTINUE',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF05403C)),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

