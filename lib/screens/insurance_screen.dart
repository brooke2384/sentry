import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/sentry_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'confirmation_screen.dart';

class InsurancePage extends StatefulWidget {
  const InsurancePage({super.key});

  @override
  _InsurancePageState createState() => _InsurancePageState();
}

class _InsurancePageState extends State<InsurancePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _insuranceNameController =
      TextEditingController();
  final TextEditingController _insuranceMemberNoController =
      TextEditingController();
  final TextEditingController _nhifNoController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _doctorLocationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInsuranceDetails();
  }

  Future<void> _fetchInsuranceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/profiles/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _insuranceNameController.text = data['insurance_name'] ?? '';
          _insuranceMemberNoController.text =
              data['insurance_member_number'] ?? '';
          _nhifNoController.text = data['nhif_number'] ?? '';
          _doctorNameController.text = data['personal_doctor_name'] ?? '';
          _doctorLocationController.text =
              data['personal_doctor_location'] ?? '';
        });
      } else {
        throw Exception(
            'Failed to load insurance details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading insurance details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveInsuranceDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.put(
        Uri.parse('https://Sentry.frobyte.ke/api/v1/profiles/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'insurance_name': _insuranceNameController.text,
          'insurance_member_number': _insuranceMemberNoController.text,
          'nhif_number': _nhifNoController.text,
          'personal_doctor_name': _doctorNameController.text,
          'personal_doctor_location': _doctorLocationController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ConfirmationPage()),
          );
        }
      } else {
        throw Exception(
            'Failed to save insurance details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving insurance details: $e';
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
      backgroundColor:
          isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDarkMode
                  ? SentryTheme.darkTextPrimary
                  : SentryTheme.lightTextPrimary),
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
                    value: 0.8333,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConfirmationPage()),
                );
              },
              child: Text(
                "Skip",
                style: TextStyle(
                    color: isDarkMode
                        ? SentryTheme.darkTextSecondary
                        : Colors.grey[600],
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Insurance Details",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? SentryTheme.darkTextPrimary
                                  : SentryTheme.primaryUltraviolet,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                    'Insurance Name', _insuranceNameController),
                                const SizedBox(height: 15),
                                _buildTextField('Insurance Member No',
                                    _insuranceMemberNoController),
                                const SizedBox(height: 15),
                                _buildTextField('NHIF No', _nhifNoController),
                                const SizedBox(height: 15),
                                _buildTextField('Personal Doctor Name',
                                    _doctorNameController),
                                const SizedBox(height: 15),
                                _buildTextField('Personal Doctor Location',
                                    _doctorLocationController),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SentryTheme.accentLime,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveInsuranceDetails,
                      child: Text(
                        'FINISH',
                        style: TextStyle(
                          fontSize: 16,
                          color: SentryTheme.primaryUltraviolet,
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

  Widget _buildTextField(String label, TextEditingController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
            color: isDarkMode ? SentryTheme.darkTextSecondary : Colors.grey),
        filled: true,
        fillColor: isDarkMode ? SentryTheme.darkSurface : Colors.grey[200],
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
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isDarkMode
            ? SentryTheme.darkTextPrimary
            : SentryTheme.lightTextPrimary,
      ),
    );
  }
}
