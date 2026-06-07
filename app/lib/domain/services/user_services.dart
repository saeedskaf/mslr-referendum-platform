import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mslr/data/env/environment.dart';
import 'package:mslr/data/local_secure/secure_storage.dart';

class UserServices {
  // Register new voter
  Future<Map<String, dynamic>> registerClient({
    required String email,
    required String fullName,
    required String dateOfBirth,
    required String password,
    required String scc,
  }) async {
    try {
      var url = Uri.parse(Environment.registerEndpoint);

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'full_name': fullName,
          'date_of_birth': dateOfBirth,
          'password': password,
          'scc_code': scc,
        }),
      );

      var responseBody = jsonDecode(response.body);

      // Success
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Registration successful',
        };
      }
      // Error
      else {
        // Extract first error from the response
        List<String> allKeys = responseBody.keys.toList();
        String errorMsg = responseBody[allKeys.first][0];
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  // Login voter
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      var url = Uri.parse(Environment.loginEndpoint);

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      var responseBody = jsonDecode(response.body);

      // Success
      if (response.statusCode == 200) {
        // Save user data to secure storage
        await secureStorage.saveUserData(
          accessToken: responseBody['access'],
          refreshToken: responseBody['refresh'],
          email: responseBody['voter']['email'],
          name: responseBody['voter']['full_name'],
        );

        return {
          'success': true,
          'message': responseBody['message'] ?? 'Login successful',
          'data': responseBody,
        };
      }
      // Error
      else {
        String errorMsg = responseBody['error'] ?? 'Login failed';
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  // Login admin
  Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      var url = Uri.parse(Environment.adminLoginEndpoint);

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      var responseBody = jsonDecode(response.body);

      // Success
      if (response.statusCode == 200) {
        // Save admin data to secure storage
        await secureStorage.saveUserData(
          accessToken: responseBody['access'] ?? '',
          refreshToken: responseBody['access'] ?? '',
          email: responseBody['email'],
          name: 'Election Commission',
        );

        return {
          'success': true,
          'message': responseBody['message'] ?? 'Login successful',
          'data': responseBody,
        };
      }
      // Error
      else {
        String errorMsg = responseBody['error'] ?? 'Login failed';
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }
}

final userServices = UserServices();
