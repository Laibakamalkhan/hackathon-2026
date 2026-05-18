import 'http_client.dart';
import 'websocket_client.dart';
import 'package:ai_seekho_flutter/core/network/models.dart';

class ApiService {
  final HttpClient _client = HttpClient();
  
  // Use 10.0.2.2 for Android Emulator, or 127.0.0.1 for Desktop/Web
  static const String baseUrl = "http://127.0.0.1:8000";
  static const String wsBaseUrl = "ws://127.0.0.1:8000";

  /// Connects to the real-time reasoning WebSocket for a specific session
  Stream<Map<String, dynamic>> connectTraceWebSocket(String sessionId) {
    final wsClient = WebSocketClient();
    return wsClient.connect("$wsBaseUrl/ws/trace/$sessionId");
  }

  /// Triggers the Google ADK Matchmaking Orchestrator
  Future<Map<String, dynamic>> matchProviders(MatchRequest request) async {
    return await _client.post(
      "$baseUrl/api/match",
      request.toJson(),
    );
  }

  /// Fetches all available providers
  Future<Map<String, dynamic>> getProviders() async {
    return await _client.get("$baseUrl/api/providers");
  }

  /// Creates a booking record in Firebase via Backend
  Future<Map<String, dynamic>> createBooking(BookingCreateRequest request) async {
    return await _client.post(
      "$baseUrl/api/booking/create",
      request.toJson(),
    );
  }
}

// Singleton instance for easy access
final ApiService apiService = ApiService();

