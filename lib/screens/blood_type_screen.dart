import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/sentry_theme.dart';
import 'insurance_screen.dart';

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
    try {
      final response = await http.post(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/profiles/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'blood_type': selectedBloodType ?? 'Unknown',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> _proceedToInsurancePage() async {
    if (selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Please select your blood type before proceeding.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _saveBloodType();
      if (mounted) {
        Navigator.pushNamed(context, '/insurance');
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        SentryTheme.primaryUltraviolet),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 29),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InsurancePage()),
                );
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
                      style: TextStyle(
                          fontSize: 16, color: SentryTheme.primaryUltraviolet),
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
