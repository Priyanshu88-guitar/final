import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  // 1. Add this static instance
  static final ApiService _instance = ApiService._internal();

  // 2. Change your default constructor to a factory
  factory ApiService() {
    return _instance;
  }

  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  // 3. Make the internal constructor private
  ApiService._internal({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl(),
        _client = client ?? http.Client();

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.239.139.74:3000/api/v1';
    } else {
      return 'http://localhost:3000/api/v1';
    }
  }

  // ... keep the rest of your exact code (setAuthToken, _buildHeaders, etc.) below this line!

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  Map<String, String> _buildHeaders([Map<String, String>? headers]) {
    final Map<String, String> map = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_authToken';
    }
    if (headers != null) {
      map.addAll(headers);
    }
    return map;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final String fullUrl = '$baseUrl$cleanEndpoint';
    final Uri uri = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final Map<String, String> stringParams = queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      return uri.replace(queryParameters: stringParams);
    }

    return uri;
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        return body;
      } else {
        return {'data': body};
      }
    }

    String errorMessage = 'Request failed with status ${response.statusCode}';
    dynamic details;

    if (body is Map<String, dynamic>) {
      if (body['message'] is String) {
        errorMessage = body['message'];
      } else if (body['error'] is String) {
        errorMessage = body['error'];
      } else if (body['error'] is Map<String, dynamic> && body['error']['message'] is String) {
        errorMessage = body['error']['message'];
      }
      
      // FIX: extract details array if available
      if (body['error'] is Map<String, dynamic> && body['error']['details'] != null) {
        details = body['error']['details'];
      } else {
        details = body['details'] ?? body['error'];
      }
    }

    debugPrint('API Error details: $details');

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      details: details,
    );
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(endpoint, queryParameters);
    final response = await _client.get(uri, headers: _buildHeaders(headers));
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(endpoint);
    final response = await _client.post(
      uri,
      headers: _buildHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(endpoint);
    final response = await _client.put(
      uri,
      headers: _buildHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(endpoint);
    final response = await _client.patch(
      uri,
      headers: _buildHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parseResponse(response);
  }

  Future<void> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(endpoint);
    final response = await _client.delete(uri, headers: _buildHeaders(headers));
    _parseResponse(response);
  }
}
