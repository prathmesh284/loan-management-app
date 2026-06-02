import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends GetxService {

  // Configure your backend URL here
  // For Lambda/AWS: use the API Gateway URL
  // For local testing: use http://localhost:8080
  final String baseUrl = "https://j1x5hhjmxe.execute-api.ap-south-1.amazonaws.com/dev";
  static const int tokenRefreshThreshold = 300; // Refresh token 5 minutes before expiry

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 [API-SERVICE] ApiService initialized with baseUrl: $baseUrl');
  }

  http.Response _buildNetworkErrorResponse(
    String scope,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('❌ [$scope] Exception: $error');
    debugPrint('📍 [$scope] Stacktrace: $stackTrace');

    final errorText = error.toString();
    final isBrowserFetchFailure = kIsWeb && errorText.contains('Failed to fetch');
    final message = isBrowserFetchFailure
        ? 'Network error: Failed to fetch. This usually means the browser blocked the request, the API is unreachable, or API Gateway CORS is not configured for this origin.'
        : 'Network error: $errorText';

    return http.Response(message, 503);
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      debugPrint('🔑 [Token] Retrieved token: ${token != null ? 'Present' : 'Not found'}');
      return token;
    } catch (e) {
      debugPrint('❌ [Token] Error getting token: $e');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token);
      debugPrint('✅ [Token] Token saved successfully');
    } catch (e) {
      debugPrint('❌ [Token] Error saving token: $e');
    }
  }

  // Check if token needs refresh
  Future<bool> _shouldRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTime = prefs.getInt("token_expiry_time") ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final needsRefresh = (expiryTime - currentTime) < tokenRefreshThreshold;
      debugPrint('🔄 [Token] Refresh needed: $needsRefresh (expires in ${expiryTime - currentTime}s)');
      return needsRefresh;
    } catch (e) {
      debugPrint('❌ [Token] Error checking refresh: $e');
      return false;
    }
  }

  Future<http.Response> getRequest(String endpoint) async {
    try {
      debugPrint('📤 [GET] Starting request to: $baseUrl$endpoint');
      String? token = await _getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ [GET] No token found for authenticated request');
        return http.Response('Unauthorized: No token found', 401);
      }

      debugPrint('🔐 [GET] Authorization header added');
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [GET] Request timeout after 30s: $endpoint');
          return http.Response('Request timeout', 408);
        },
      );

      debugPrint('📥 [GET] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [GET] Error response: ${response.body}');
      }
      _handleTokenExpiry(response.statusCode);
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('GET', e, stackTrace);
    }
  }

  MediaType _contentTypeForPath(String path) {
    final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
    return MediaType.parse(mimeType);
  }

  Future<http.Response> postRequest(String endpoint, Map body) async {
    try {
      debugPrint('📤 [POST] Starting request to: $baseUrl$endpoint');
      debugPrint('📦 [POST] Body: ${jsonEncode(body)}');
      String? token = await _getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ [POST] No token found for authenticated request');
        return http.Response('Unauthorized: No token found', 401);
      }

      debugPrint('🔐 [POST] Authorization header added');
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [POST] Request timeout after 30s: $endpoint');
          return http.Response('Request timeout', 408);
        },
      );

      debugPrint('📥 [POST] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [POST] Error response: ${response.body}');
      }
      _handleTokenExpiry(response.statusCode);
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('POST', e, stackTrace);
    }
  }

  // ✅ PUT Request
  Future<http.Response> putRequest(String endpoint, Map body) async {
    try {
      debugPrint('📤 [PUT] Starting request to: $baseUrl$endpoint');
      debugPrint('📦 [PUT] Body: ${jsonEncode(body)}');
      String? token = await _getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ [PUT] No token found for authenticated request');
        return http.Response('Unauthorized: No token found', 401);
      }

      debugPrint('🔐 [PUT] Authorization header added');
      final response = await http.put(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [PUT] Request timeout after 30s: $endpoint');
          return http.Response('Request timeout', 408);
        },
      );

      debugPrint('📥 [PUT] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [PUT] Error response: ${response.body}');
      }
      _handleTokenExpiry(response.statusCode);
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('PUT', e, stackTrace);
    }
  }

  // ✅ DELETE Request
  Future<http.Response> deleteRequest(String endpoint) async {
    try {
      debugPrint('📤 [DELETE] Starting request to: $baseUrl$endpoint');
      String? token = await _getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ [DELETE] No token found for authenticated request');
        return http.Response('Unauthorized: No token found', 401);
      }

      debugPrint('🔐 [DELETE] Authorization header added');
      final response = await http.delete(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [DELETE] Request timeout after 30s: $endpoint');
          return http.Response('Request timeout', 408);
        },
      );

      debugPrint('📥 [DELETE] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [DELETE] Error response: ${response.body}');
      }
      _handleTokenExpiry(response.statusCode);
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('DELETE', e, stackTrace);
    }
  }

  // ✅ File Upload with multipart/form-data
  Future<http.Response> uploadFile(String endpoint, String filePath, String fieldName) async {
    try {
      debugPrint('📤 [UPLOAD] Starting file upload to: $baseUrl$endpoint');
      debugPrint('📁 [UPLOAD] File path: $filePath | Field: $fieldName');
      String? token = await _getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ [UPLOAD] No token found for authenticated request');
        return http.Response('Unauthorized: No token found', 401);
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl$endpoint"),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔐 [UPLOAD] Authorization header added');

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          filePath,
          contentType: _contentTypeForPath(filePath),
        ),
      );
      debugPrint('📎 [UPLOAD] File attached to request');

      // Send request with timeout
      var streamResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('⏱️ [UPLOAD] Request timeout after 60s: $endpoint');
          throw TimeoutException('Upload timeout');
        },
      );

      var response = await http.Response.fromStream(streamResponse);
      debugPrint('📥 [UPLOAD] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [UPLOAD] Error response: ${response.body}');
      }
      _handleTokenExpiry(response.statusCode);
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('UPLOAD', e, stackTrace);
    }
  }

  // ✅ Upload Multiple Files
  Future<http.Response> uploadMultipleFiles(
    String endpoint,
    List<String> filePaths,
    String fieldName,
  ) async {
    try {
      debugPrint('📤 [MULTI-UPLOAD] Starting multi-file upload to: $baseUrl$endpoint');
      debugPrint('📁 [MULTI-UPLOAD] Files count: ${filePaths.length} | Field: $fieldName');
      String? token = await _getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ [MULTI-UPLOAD] No token found for authenticated request');
        return http.Response('Unauthorized: No token found', 401);
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl$endpoint"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔐 [MULTI-UPLOAD] Authorization header added');

      for (String filePath in filePaths) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            filePath,
            contentType: _contentTypeForPath(filePath),
          ),
        );
        debugPrint('📎 [MULTI-UPLOAD] File attached: $filePath');
      }

      var streamResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('⏱️ [MULTI-UPLOAD] Request timeout after 60s: $endpoint');
          throw TimeoutException('Upload timeout');
        },
      );

      var response = await http.Response.fromStream(streamResponse);
      debugPrint('📥 [MULTI-UPLOAD] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [MULTI-UPLOAD] Error response: ${response.body}');
      }
      _handleTokenExpiry(response.statusCode);
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('MULTI-UPLOAD', e, stackTrace);
    }
  }

  // ✅ Upload File with Additional Fields
  Future<http.Response> uploadFileWithFields(
    String endpoint,
    String? filePath,
    String fieldName,
    Map<String, String> additionalFields,
  ) async {
    try {
      debugPrint('📤 [UPLOAD-FIELDS] Starting file upload with fields to: $baseUrl$endpoint');
      debugPrint('📁 [UPLOAD-FIELDS] File: $filePath | Field: $fieldName | Additional fields: ${additionalFields.length}');
      String? token = await _getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ [UPLOAD-FIELDS] No token found for authenticated request');
        return http.Response('Unauthorized: No token found', 401);
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl$endpoint"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔐 [UPLOAD-FIELDS] Authorization header added');

      // Add file only if filePath is provided (not null)
      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            filePath,
            contentType: _contentTypeForPath(filePath),
          ),
        );
        debugPrint('📎 [UPLOAD-FIELDS] File attached: $filePath');
      } else {
        debugPrint('⚠️ [UPLOAD-FIELDS] No file provided (filePath is null)');
      }

      // Add additional fields
      additionalFields.forEach((key, value) {
        request.fields[key] = value;
        debugPrint('📝 [UPLOAD-FIELDS] Field added: $key = $value');
      });

      var streamResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('⏱️ [UPLOAD-FIELDS] Request timeout after 60s: $endpoint');
          throw TimeoutException('Upload timeout');
        },
      );

      var response = await http.Response.fromStream(streamResponse);
      debugPrint('📥 [UPLOAD-FIELDS] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [UPLOAD-FIELDS] Error response: ${response.body}');
      }
      _handleTokenExpiry(response.statusCode);
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('UPLOAD-FIELDS', e, stackTrace);
    }
  }

  // ✅ Public GET Request (No Token Required)
  // Used for endpoints like /api/branches, /api/auth/login, /api/auth/signup
  Future<http.Response> publicGetRequest(String endpoint) async {
    try {
      debugPrint('📤 [PUBLIC-GET] Starting public request to: $baseUrl$endpoint');
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [PUBLIC-GET] Request timeout after 30s: $endpoint');
          return http.Response('Request timeout', 408);
        },
      );

      debugPrint('📥 [PUBLIC-GET] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [PUBLIC-GET] Error response: ${response.body}');
      }
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('PUBLIC-GET', e, stackTrace);
    }
  }

  // ✅ Public POST Request (No Token Required)
  // Used for endpoints like /api/auth/login, /api/auth/signup
  Future<http.Response> publicPostRequest(String endpoint, Map body) async {
    try {
      debugPrint('📤 [PUBLIC-POST] Starting public request to: $baseUrl$endpoint');
      debugPrint('📦 [PUBLIC-POST] Body: ${jsonEncode(body)}');
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [PUBLIC-POST] Request timeout after 30s: $endpoint');
          return http.Response('Request timeout', 408);
        },
      );

      debugPrint('📥 [PUBLIC-POST] Response status: ${response.statusCode} | Body length: ${response.body.length}');
      if (response.statusCode >= 400) {
        debugPrint('⚠️ [PUBLIC-POST] Error response: ${response.body}');
      }
      return response;
    } catch (e, stackTrace) {
      return _buildNetworkErrorResponse('PUBLIC-POST', e, stackTrace);
    }
  }

  // ✅ Handle Token Expiry / Invalid Token
  void _handleTokenExpiry(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      // Clear stored token and redirect to login
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove("jwt_token");
        prefs.remove("token_expiry_time");
        prefs.remove("branch_id");
        Get.offAllNamed('/login');
      });
    }
  }

  // ✅ Store Token with Expiry Time
  Future<void> storeTokenData(String token, {int? expirySeconds}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
    
    if (expirySeconds != null) {
      final expiryTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + expirySeconds;
      await prefs.setInt("token_expiry_time", expiryTime);
    }
  }

  // ✅ Logout - Clear all stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
    await prefs.remove("token_expiry_time");
    await prefs.remove("branch_id");
  }
}
