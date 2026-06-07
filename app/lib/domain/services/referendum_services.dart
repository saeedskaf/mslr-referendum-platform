import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mslr/data/env/environment.dart';
import 'package:mslr/data/local_secure/secure_storage.dart';
import 'package:mslr/domain/models/admin_referendum_model.dart';
import 'package:mslr/domain/models/referendum_model.dart';

class ReferendumService {
  // Get all referendums for voter
  Future<Map<String, dynamic>> getAllReferendums() async {
    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken == null) {
        return {'success': false, 'message': 'Please login first'};
      }

      var url = Uri.parse(Environment.voterReferendumsEndpoint);

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body) as List;

        VoterReferendumModel model = VoterReferendumModel.fromJson(
          responseBody,
        );

        return {
          'success': true,
          'message': 'Referendums loaded successfully',
          'data': model,
        };
      } else {
        return {'success': false, 'message': 'Failed to load referendums'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  // Cast vote
  Future<Map<String, dynamic>> castVote({
    required String referendumId,
    required String optionId,
  }) async {
    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken == null) {
        return {'success': false, 'message': 'Please login first'};
      }

      var url = Uri.parse(Environment.castVoteEndpoint);

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'referendum': referendumId, 'option': optionId}),
      );
      print(response.body);

      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Vote cast successfully',
        };
      } else {
        return {'success': false, 'message': 'Failed to cast vote'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  // Get all referendums for admin
  Future<Map<String, dynamic>> getAllAdminReferendums() async {
    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken == null) {
        return {'success': false, 'message': 'Please login first'};
      }
      var url = Uri.parse(Environment.adminReferendumsEndpoint);

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body) as List;

        AdminReferendumModel model = AdminReferendumModel.fromJson(
          responseBody,
        );

        return {
          'success': true,
          'message': 'Referendums loaded successfully',
          'data': model,
        };
      } else {
        return {'success': false, 'message': 'Failed to load referendums'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  // Create new referendum
  Future<Map<String, dynamic>> createReferendum({
    required String title,
    required String description,
    required List<String> options,
  }) async {
    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken == null) {
        return {'success': false, 'message': 'Please login first'};
      }
      var url = Uri.parse("${Environment.adminReferendumsEndpoint}create/");
      // Format options correctly
      List<Map<String, String>> formattedOptions = options.map((option) {
        return {'option_text': option};
      }).toList();

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'title': title,
        'description': description,
        'options': formattedOptions,
        'status': 'closed', // New referendums start as closed
      };

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );
      print(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Referendum created successfully'};
      } else {
        return {'success': false, 'message': 'Failed to create referendum'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  // Update existing referendum
  Future<Map<String, dynamic>> updateReferendum({
    required int referendumId,
    required String title,
    required String description,
    required List<String> options,
  }) async {
    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken == null) {
        return {'success': false, 'message': 'Please login first'};
      }
      var url = Uri.parse(
        '${Environment.adminReferendumsEndpoint}$referendumId/update/',
      );
      // Format options correctly
      List<Map<String, String>> formattedOptions = options.map((option) {
        return {'option_text': option};
      }).toList();

      Map<String, dynamic> requestBody = {
        'title': title,
        'description': description,
        'options': formattedOptions,
      };

      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );
      print(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Referendum updated successfully'};
      } else {
        return {'success': false, 'message': 'Failed to update referendum'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  // Toggle referendum status (open/close)
  Future<Map<String, dynamic>> toggleReferendumStatus(
    int referendumId,
    String newStatus,
  ) async {
    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken == null) {
        return {'success': false, 'message': 'Please login first'};
      }
      var url = Uri.parse(
        '${Environment.adminReferendumsEndpoint}$referendumId/update/',
      );

      var response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'status': newStatus}),
      );
      print(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Referendum status updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update referendum status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }
}

final referendumService = ReferendumService();
