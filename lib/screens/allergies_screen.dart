import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sentry/theme/sentry_theme.dart';
import 'dart:convert';

class AllergyPage extends StatefulWidget {
  const AllergyPage({super.key});

  @override
  _AllergyPageState createState() => _AllergyPageState();
}

class _AllergyPageState extends State<AllergyPage> {
  String? hasAllergies;
  String allergyType = '';
  bool _isLoading = false;

  // Replace with your API endpoint
  final String _apiEndpoint = 'https://Sentry.frobyte.ke/api/v1/profiles/';

  // Function to save allergy data using the custom API
  Future<void> _saveAllergyData() async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'is_allergic': hasAllergies == 'Yes',
          'allergy_type': allergyType.isEmpty ? 'None' : allergyType,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> _proceedToNextPage() async {
    if (hasAllergies == null ||
        (hasAllergies == 'Yes' && allergyType.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all required fields.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _saveAllergyData();
      if (mounted) {
        Navigator.pushNamed(context, '/medicine');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        iconTheme: IconThemeData(
          color: isDarkMode
              ? SentryTheme.darkTextPrimary
              : SentryTheme.lightTextPrimary,
        ),
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
                    value: 0.3333, // 33.33% progress
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        SentryTheme.primaryUltraviolet),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 29),
            // Skip button
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/medicine'); // Skip to next page
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                    color: SentryTheme.primaryUltraviolet,
                    fontWeight: FontWeight.bold),
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
                    "Do you have any allergies?",
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
                            hasAllergies = 'Yes';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasAllergies == 'Yes'
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
                            hasAllergies = 'No';
                            allergyType =
                                ''; // Clear allergy type if "No" is selected
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasAllergies == 'No'
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
                  if (hasAllergies == 'Yes')
                    SizedBox(
                      width: double.infinity, // Full width for the text field
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Type of allergy',
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
                            allergyType = value;
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
