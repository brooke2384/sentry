import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/sentry_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalProfilePage extends StatefulWidget {
  const MedicalProfilePage({super.key});

  @override
  State<MedicalProfilePage> createState() => _MedicalProfilePageState();
}

class _MedicalProfilePageState extends State<MedicalProfilePage> {
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMedicalData();
  }

  Future<void> _fetchMedicalData() async {
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
          _allergiesController.text = data['allergy_type'] ?? '';
          _medicationsController.text = data['maintenance_medicine_type'] ?? '';
          _bloodTypeController.text = data['blood_type'] ?? '';
        });
      } else {
        throw Exception('Failed to load medical data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading medical data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMedicalData() async {
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
          'allergy_type': _allergiesController.text,
          'maintenance_medicine_type': _medicationsController.text,
          'blood_type': _bloodTypeController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Medical information updated successfully!')),
          );
        }
      } else {
        throw Exception(
            'Failed to update medical data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating medical data: $e';
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
        title: Text(
          'Medical Profile',
          style: TextStyle(
            color: isDarkMode
                ? SentryTheme.darkTextPrimary
                : SentryTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode
                  ? SentryTheme.darkTextPrimary
                  : SentryTheme.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    Text(
                      'Medical Information',
                      style: TextStyle(
                        color: isDarkMode
                            ? SentryTheme.darkTextPrimary
                            : SentryTheme.primaryUltraviolet,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Allergies',
                      _allergiesController,
                      enabled: _isEditing,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your allergies'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Current Medications',
                      _medicationsController,
                      enabled: _isEditing,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your medications'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Blood Type',
                      _bloodTypeController,
                      enabled: _isEditing,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your blood type'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_isEditing) {
                                  _updateMedicalData();
                                } else {
                                  setState(() => _isEditing = true);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SentryTheme.accentLime,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 24.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isEditing
                              ? 'Save Medical Information'
                              : 'Edit Medical Information',
                          style:
                              TextStyle(color: SentryTheme.primaryUltraviolet),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? SentryTheme.darkTextSecondary : Colors.grey[600],
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: enabled
            ? null
            : (isDarkMode ? SentryTheme.darkSurface : Colors.grey[200]),
      ),
    );
  }
}
