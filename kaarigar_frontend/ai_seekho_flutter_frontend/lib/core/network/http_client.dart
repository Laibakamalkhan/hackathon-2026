import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thrown when the backend returns a non-2xx status code.
class HttpException implements Exception {
  final int statusCode;
  final String message;

  const HttpException(this.statusCode, this.message);

  @override
  String toString() => 'HttpException [$statusCode]: $message';
}

/// Lightweight wrapper around [http.Client] that:
/// - Sets `Content-Type: application/json` on every request.
/// - Parses the JSON response body automatically.
/// - Throws [HttpException] on non-2xx status codes.
/// - Wraps socket / network errors as [HttpException] with status 500.
class HttpClient {
  static String? bearerToken;
  static String? demoUid;

  final http.Client _client = http.Client();

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (bearerToken != null) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }
    if (demoUid != null) {
      headers['X-User-Id'] = demoUid!;
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException(500, 'Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException(500, 'Network error: ${e.toString()}');
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      // Wrap non-map responses (e.g. list at root) under "data".
      return {'data': decoded};
    }
    final errorMsg = decoded is Map
        ? (decoded['detail'] ?? decoded['message'] ?? 'Unknown error')
        : response.body;
    throw HttpException(response.statusCode, errorMsg.toString());
  }
}
