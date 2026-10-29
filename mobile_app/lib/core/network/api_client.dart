import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient = http.Client();

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? EnvConfig.instance.apiBaseUrl;

  Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-user-id': 'user_rahul_01',
    };
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// Check server health & database connection
  Future<Map<String, dynamic>> checkHealth() async {
    return await get('/health');
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      debugPrint('[ApiClient GET] $uri');
    }
    try {
      final response = await _httpClient
          .get(uri, headers: _buildHeaders(headers))
          .timeout(const Duration(seconds: 5));
      final isHttpOk = response.statusCode >= 200 && response.statusCode < 300;
      if (response.body.isEmpty) {
        return {'success': isHttpOk};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (!decoded.containsKey('success')) {
          decoded['success'] = isHttpOk;
        } else if (!isHttpOk) {
          decoded['success'] = false;
        }
        return decoded;
      }
      return {'success': isHttpOk, 'data': decoded};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiClient GET Error] $uri -> $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      debugPrint('[ApiClient POST] $uri with data: $data');
    }
    try {
      final requestHeaders = _buildHeaders(headers);
      final response = await _httpClient
          .post(
            uri,
            headers: requestHeaders,
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(const Duration(seconds: 5));
      final isHttpOk = response.statusCode >= 200 && response.statusCode < 300;
      if (response.body.isEmpty) {
        return {'success': isHttpOk};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (!decoded.containsKey('success')) {
          decoded['success'] = isHttpOk;
        } else if (!isHttpOk) {
          decoded['success'] = false;
        }
        return decoded;
      }
      return {'success': isHttpOk, 'data': decoded};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiClient POST Error] $uri -> $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      debugPrint('[ApiClient PUT] $uri with data: $data');
    }
    try {
      final requestHeaders = _buildHeaders(headers);
      final response = await _httpClient
          .put(
            uri,
            headers: requestHeaders,
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(const Duration(seconds: 5));
      final isHttpOk = response.statusCode >= 200 && response.statusCode < 300;
      if (response.body.isEmpty) {
        return {'success': isHttpOk};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (!decoded.containsKey('success')) {
          decoded['success'] = isHttpOk;
        } else if (!isHttpOk) {
          decoded['success'] = false;
        }
        return decoded;
      }
      return {'success': isHttpOk, 'data': decoded};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiClient PUT Error] $uri -> $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      debugPrint('[ApiClient DELETE] $uri');
    }
    try {
      final response = await _httpClient
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(const Duration(seconds: 5));
      final isHttpOk = response.statusCode >= 200 && response.statusCode < 300;
      if (response.body.isEmpty) {
        return {'success': isHttpOk};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (!decoded.containsKey('success')) {
          decoded['success'] = isHttpOk;
        } else if (!isHttpOk) {
          decoded['success'] = false;
        }
        return decoded;
      }
      return {'success': isHttpOk, 'data': decoded};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiClient DELETE Error] $uri -> $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }
}
