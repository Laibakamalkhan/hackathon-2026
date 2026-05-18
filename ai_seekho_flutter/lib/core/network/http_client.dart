import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpException implements Exception {
  final int statusCode;
  final String message;
  HttpException(this.statusCode, this.message);
  @override
  String toString() => "HttpException: [$statusCode] $message";
}

class HttpClient {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      return _processResponse(response);
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException(500, "Network connection error: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException(500, "Network connection error: ${e.toString()}");
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {"data": decoded};
    } else {
      final errorMsg = decoded is Map
          ? decoded['detail'] ?? "Unknown error"
          : response.body;
      throw HttpException(response.statusCode, errorMsg.toString());
    }
  }
}
