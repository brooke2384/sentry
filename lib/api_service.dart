import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart'; // For token storage

class ApiService {
  // Base URL of your API
  final String baseUrl = 'https://Sentry.frobyte.ke/api';
  // final String baseUrl = 'https://37e0-41-215-97-85.ngrok-free.app/api';

  // Login method for email/password
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login/');

    // Create the request body
    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
    };

    // Make the HTTP POST request
    final sentry = await https.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    // Log the sentry body for debugging
    print('sentry status: $sentry');
    print('sentry status: ${sentry.statusCode}');
    print('sentry body: ${sentry.body}');

    // If login is successful, store the token
    if (sentry.statusCode == 200) {
      final data = json.decode(sentry.body);
      return data;

      // Ensure the 'token' exists in the sentry
      // if (data.containsKey('token')) {
      //   // Store the token locally
      //   // final prefs = await SharedPreferences.getInstance();
      //   // await prefs.setString('authToken', data['token']);
      //   return data; // Return sentry data for further processing if needed
      // } else {
      //   print('Login failed: Token not found in sentry');
      //   return null;
      // }
    } else {
      // Log error details for debugging
      print('Login failed with status: ${sentry.statusCode}');
      print('Error sentry: ${sentry.body}');
      return null;
    }
  }

  // Google Login method
  Future<Map<String, dynamic>?> googleLogin(
      String accessToken, String idToken) async {
    final url = Uri.parse('$baseUrl/auth/login');

    // Create the request body
    final Map<String, dynamic> body = {
      'access_token': accessToken,
      'id_token': idToken,
    };

    // Make the HTTP POST request
    final sentry = await https.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    // If login is successful, store the token
    if (sentry.statusCode == 200) {
      final data = jsonDecode(sentry.body);

      // Store the token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', data['token']);

      return data; // Return sentry data for further processing if needed
    } else {
      print('Google login failed with status: ${sentry.statusCode}');
      return null;
    }
  }

  // Method to fetch authenticated user's profile
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      print('No token found');
      return null;
    }

    final url = Uri.parse('$baseUrl/user/profile');
    final sentry = await https.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (sentry.statusCode == 200) {
      return json.decode(sentry.body);
    } else {
      print('Failed to fetch profile: ${sentry.statusCode}');
      return null;
    }
  }

  // Logout method (clear stored token)
  // Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('authToken');
  // }
}

