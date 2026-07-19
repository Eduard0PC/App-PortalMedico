import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5250';
    }
    return Platform.isAndroid ? 'http://10.0.2.2:5250' : 'http://localhost:5250';
  }

  Map<String, String> _buildHeaders({String? token, Map<String, String>? extraHeaders}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<http.Response> get(String path, {String? token, Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.get(uri, headers: _buildHeaders(token: token)).timeout(timeout);
  }

  Future<http.Response> post(String path, {Object? body, String? token, Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);
    return await http.post(uri, headers: _buildHeaders(token: token), body: encodedBody).timeout(timeout);
  }

  Future<http.Response> put(String path, {Object? body, String? token, Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);
    return await http.put(uri, headers: _buildHeaders(token: token), body: encodedBody).timeout(timeout);
  }

  Future<http.Response> patch(String path, {Object? body, String? token, Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);
    return await http.patch(uri, headers: _buildHeaders(token: token), body: encodedBody).timeout(timeout);
  }

  dynamic parseResponseData(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map && decoded.containsKey('data') && (decoded.containsKey('success') || decoded.containsKey('message'))) {
        return decoded['data'] ?? decoded;
      }
      return decoded;
    } catch (e) {
      debugPrint('Error parseResponseData: $e');
      return null;
    }
  }

  String extractErrorMessage(String responseBody, String defaultMessage) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map) {
        if (decoded['data'] != null && decoded['data'] is Map) {
          final Map<String, dynamic> fieldErrors = Map<String, dynamic>.from(decoded['data']);
          final List<String> errorList = [];
          fieldErrors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.map((e) => e.toString()));
            } else if (value != null) {
              errorList.add(value.toString());
            }
          });
          if (errorList.isNotEmpty) {
            return errorList.join('\n');
          }
        }
        if (decoded['message'] != null && decoded['message'].toString().isNotEmpty) {
          return decoded['message'].toString();
        }
        if (decoded['detail'] != null && decoded['detail'].toString().isNotEmpty) {
          return decoded['detail'].toString();
        }
      }
    } catch (_) {}
    return defaultMessage;
  }
}
