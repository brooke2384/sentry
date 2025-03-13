import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/sentry_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEmergencyContact();
  }

  Future<void> _fetchEmergencyContact() async {
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
          _contactNameController.text = data['emergency_contact_name'] ?? '';
          _contactPhoneController.text = data['emergency_contact_phone'] ?? '';
        });
      } else {
        throw Exception('Failed to load contact data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading emergency contacts: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateEmergencyContact() async {
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
          'emergency_contact_name': _contactNameController.text,
          'emergency_contact_phone': _contactPhoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Emergency contact updated successfully!')),
          );
        }
      } else {
        throw Exception('Failed to update contact: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating emergency contact: $e';
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
          'Emergency Contacts',
          style: TextStyle(
            color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.lightTextPrimary),
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
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    Text(
                      'Emergency Contact Information',
                      style: TextStyle(
                        color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Contact Name',
                      _contactNameController,
                      enabled: _isEditing,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter contact name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Contact Phone Number',
                      _contactPhoneController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter phone number' : null,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          if (_isEditing) {
                            _updateEmergencyContact();
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
                          _isEditing ? 'Save Emergency Contact' : 'Edit Emergency Contact',
                          style: TextStyle(color: SentryTheme.primaryUltraviolet),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? SentryTheme.darkTextSecondary : Colors.grey[600],
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: enabled ? null : (isDarkMode ? SentryTheme.darkSurface : Colors.grey[200]),
      ),
    );
  }
}

