import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String host;
  final Map<String, String> defaultHeaders;

  ApiService({
    required this.host,
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = defaultHeaders ??
            {
              'Content-Type': 'application/json',
            };

  /// Sends a POST request with JSON body to [path]
  /// Returns decoded JSON response as Map<String, dynamic>
  Future<Map<String, dynamic>> postJson({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(_buildUrl(path));

    final response = await http.post(
      uri,
      headers: {
        ...defaultHeaders,
        if (headers != null) ...headers,
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Internal: Build full URL from host + path
  String _buildUrl(String path) {
    if (path.startsWith('/')) {
      return '$host$path';
    }
    return '$host/$path';
  }

  /// Internal: Handle response + errors
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) {
        return {};
      }
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } else {
      throw ApiException(
        statusCode: statusCode,
        message: responseBody,
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
