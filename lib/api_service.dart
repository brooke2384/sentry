import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart'; // For token storage

class ApiService {
  // Base URL of your API
  final String baseUrl = 'https://responda.frobyte.ke/api';
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
    final response = await https.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    // Log the response body for debugging
    print('Response status: ${response}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // If login is successful, store the token
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;

      // Ensure the 'token' exists in the response
      // if (data.containsKey('token')) {
      //   // Store the token locally
      //   // final prefs = await SharedPreferences.getInstance();
      //   // await prefs.setString('authToken', data['token']);
      //   return data; // Return response data for further processing if needed
      // } else {
      //   print('Login failed: Token not found in response');
      //   return null;
      // }
    } else {
      // Log error details for debugging
      print('Login failed with status: ${response.statusCode}');
      print('Error response: ${response.body}');
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
    final response = await https.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    // If login is successful, store the token
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Store the token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', data['token']);

      return data; // Return response data for further processing if needed
    } else {
      print('Google login failed with status: ${response.statusCode}');
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
    final response = await https.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to fetch profile: ${response.statusCode}');
      return null;
    }
  }

  // Logout method (clear stored token)
  // Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('authToken');
  // }
}
