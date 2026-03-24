import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends GetxService {

  final String baseUrl = "http://localhost:8080";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<http.Response> getRequest(String endpoint) async {
    String? token = await _getToken();

    return await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
  }

  Future<http.Response> postRequest(String endpoint, Map body) async {
    String? token = await _getToken();

    return await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(body),
    );
  }

  // ✅ PUT Request
  Future<http.Response> putRequest(String endpoint, Map body) async {
    String? token = await _getToken();

    return await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(body),
    );
  }

  // ✅ DELETE Request
  Future<http.Response> deleteRequest(String endpoint) async {
    String? token = await _getToken();

    return await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
  }

  // ✅ File Upload with multipart/form-data
  Future<http.Response> uploadFile(String endpoint, String filePath, String fieldName) async {
    String? token = await _getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl$endpoint"),
    );

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add file
    request.files.add(
      await http.MultipartFile.fromPath(fieldName, filePath),
    );

    // Send request
    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  // ✅ Upload Multiple Files
  Future<http.Response> uploadMultipleFiles(
    String endpoint,
    List<String> filePaths,
    String fieldName,
  ) async {
    String? token = await _getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl$endpoint"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    for (String filePath in filePaths) {
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, filePath),
      );
    }

    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  // ✅ Upload File with Additional Fields
  Future<http.Response> uploadFileWithFields(
    String endpoint,
    String filePath,
    String fieldName,
    Map<String, String> additionalFields,
  ) async {
    String? token = await _getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl$endpoint"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Add file
    request.files.add(
      await http.MultipartFile.fromPath(fieldName, filePath),
    );

    // Add additional fields
    additionalFields.forEach((key, value) {
      request.fields[key] = value;
    });

    var response = await request.send();
    return await http.Response.fromStream(response);
  }
}