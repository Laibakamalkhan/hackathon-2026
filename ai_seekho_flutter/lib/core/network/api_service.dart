import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_client.dart';
import 'websocket_client.dart';
import 'package:ai_seekho_flutter/core/network/models.dart';
import 'package:ai_seekho_flutter/core/constants/api_endpoints.dart';

class ApiService {
  final HttpClient _client = HttpClient();

  // ── Legacy: WebSocket for old trace endpoint ──────────────────
  Stream<Map<String, dynamic>> connectTraceWebSocket(String sessionId) {
    final wsClient = WebSocketClient();
    return wsClient.connect(ApiEndpoints.wsTrace(sessionId));
  }

  // ── NEW: WebSocket for real-time agent stream ─────────────────
  Stream<Map<String, dynamic>> connectAgentStream() {
    final wsClient = WebSocketClient();
    return wsClient.connect(ApiEndpoints.wsAgentStream);
  }

  // ── Legacy: matchProviders (old /api/match endpoint) ──────────
  Future<Map<String, dynamic>> matchProviders(MatchRequest request) async {
    return await _client.post(ApiEndpoints.match, request.toJson());
  }

  /// Fetches all available providers
  Future<Map<String, dynamic>> getProviders() async {
    return await _client.get(ApiEndpoints.providers);
  }

  /// Creates a booking record (legacy endpoint)
  Future<Map<String, dynamic>> createBooking(BookingCreateRequest request) async {
    return await _client.post(ApiEndpoints.bookingCreate, request.toJson());
  }

  // ── NEW v1: Agent Coordinate ──────────────────────────────────
  /// Runs the CoordinatorAgent: intent → provider search → price quote.
  /// Supports multi-turn via conversationHistory.
  Future<Map<String, dynamic>> agentCoordinate({
    required String query,
    required double lat,
    required double lng,
    String sessionId = 'session-default',
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    return await _client.post(ApiEndpoints.agentCoordinate, {
      'query': query,
      'lat': lat,
      'lng': lng,
      'session_id': sessionId,
      if (conversationHistory != null) 'conversation_history': conversationHistory,
    });
  }

  // ── NEW v1: Agent Execute ─────────────────────────────────────
  /// Runs the ExecutorAgent: locks slot + creates Firestore booking.
  Future<Map<String, dynamic>> agentExecute({
    required Map<String, dynamic> handoff,
  }) async {
    return await _client.post(ApiEndpoints.agentExecute, {'handoff': handoff});
  }

  // ── NEW v1: Agent Resolve Dispute ─────────────────────────────
  /// Runs the GuardianAgent: dispute resolution via Gemini + refund table.
  Future<Map<String, dynamic>> resolveDispute({
    required String bookingId,
    required String disputeType,
    required String description,
    String userId = 'user_demo_001',
  }) async {
    return await _client.post(ApiEndpoints.agentResolve, {
      'booking_id': bookingId,
      'dispute_type': disputeType,
      'description': description,
      'user_id': userId,
    });
  }

  // ── NEW v1: Submit Feedback ───────────────────────────────────
  /// Submits feedback and updates provider reputation.
  Future<Map<String, dynamic>> submitFeedback({
    required String bookingId,
    required double rating,
    required String comment,
    String userId = 'user_demo_001',
  }) async {
    return await _client.post(ApiEndpoints.feedbackSubmit, {
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'user_id': userId,
    });
  }

  // ── NEW v1: Get User Bookings ─────────────────────────────────
  /// Returns all bookings for a given user from Firestore.
  Future<Map<String, dynamic>> getUserBookings(String userId) async {
    return await _client.get('${ApiEndpoints.getBookings}?user_id=$userId');
  }

  // ── NEW v1: Update Booking Status ────────────────────────────
  /// Updates booking status (confirmed, en_route, completed, cancelled...).
  Future<Map<String, dynamic>> updateBookingStatus(
    String bid,
    String newStatus,
  ) async {
    final url = ApiEndpoints.updateBookingStatus(bid);
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {'error': 'Status update failed: ${response.statusCode}', 'body': response.body};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

// Singleton instance
final ApiService apiService = ApiService();
