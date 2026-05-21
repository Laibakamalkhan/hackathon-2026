import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_seekho/core/network/http_client.dart';
import 'package:ai_seekho/core/network/websocket_client.dart';
import 'package:ai_seekho/core/network/models.dart';
import 'package:ai_seekho/core/constants/api_endpoints.dart';

/// Central API service for KARIGAR.
///
/// Wraps every backend endpoint. Instantiate once and reuse the
/// [apiService] singleton at the bottom of this file.
class ApiService {
  final HttpClient _client = HttpClient();

  // ── Providers ────────────────────────────────────────────────────────────

  /// GET /api/providers — fetches all registered service providers.
  Future<Map<String, dynamic>> getProviders() async {
    return _client.get(ApiEndpoints.providers);
  }

  // ── v1 Agent: Coordinate ─────────────────────────────────────────────────

  /// POST /api/v1/agent/coordinate
  ///
  /// Runs the CoordinatorAgent: parses the user's intent, finds nearby
  /// providers, and returns a ranked list with a price quote.
  Future<Map<String, dynamic>> agentCoordinate({
    required String query,
    required double lat,
    required double lng,
    String sessionId = 'session-default',
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    final body = CoordinateRequest(
      query: query,
      lat: lat,
      lng: lng,
      sessionId: sessionId,
      conversationHistory: conversationHistory,
    ).toJson();
    return _client.post(ApiEndpoints.agentCoordinate, body);
  }

  // ── v1 Agent: Execute ────────────────────────────────────────────────────

  /// POST /api/v1/agent/execute
  ///
  /// Runs the ExecutorAgent: locks the provider's time slot and creates
  /// a permanent Firestore booking record.
  ///
  /// [handoff] is the object returned by the coordinator's response.
  Future<Map<String, dynamic>> agentExecute({
    required Map<String, dynamic> handoff,
  }) async {
    return _client.post(ApiEndpoints.agentExecute, {'handoff': handoff});
  }

  // ── v1 Agent: Resolve Dispute ────────────────────────────────────────────

  /// POST /api/v1/agent/resolve
  ///
  /// Runs the GuardianAgent: resolves a dispute using Gemini and the
  /// platform's refund policy table.
  Future<Map<String, dynamic>> resolveDispute({
    required String bookingId,
    required String disputeType,
    required String description,
    String userId = 'user_demo_001',
  }) async {
    return _client.post(ApiEndpoints.agentResolve, {
      'booking_id': bookingId,
      'dispute_type': disputeType,
      'description': description,
      'user_id': userId,
    });
  }

  // ── v1 Feedback ──────────────────────────────────────────────────────────

  /// POST /api/v1/feedback/submit
  ///
  /// Saves the user's feedback and updates the provider's reputation score.
  Future<Map<String, dynamic>> submitFeedback({
    required String bookingId,
    required double rating,
    required String comment,
    String userId = 'user_demo_001',
  }) async {
    return _client.post(ApiEndpoints.feedbackSubmit, {
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'user_id': userId,
    });
  }

  // ── v1 Bookings ──────────────────────────────────────────────────────────

  /// GET /api/v1/bookings?user_id={userId}
  ///
  /// Returns all bookings for the given user from Firestore.
  Future<Map<String, dynamic>> getUserBookings(String userId) async {
    return _client.get('${ApiEndpoints.getBookings}?user_id=$userId');
  }

  /// PATCH /api/v1/booking/{bid}/status
  ///
  /// Updates status and/or scheduled_time. At least one field is required.
  Future<Map<String, dynamic>> patchBooking(
    String bid, {
    String? status,
    String? scheduledTime,
  }) async {
    if (status == null && scheduledTime == null) {
      return {'error': 'At least one of status or scheduled_time is required'};
    }
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (scheduledTime != null) body['scheduled_time'] = scheduledTime;

    final url = ApiEndpoints.updateBookingStatus(bid);
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        'error': 'Booking patch failed: ${response.statusCode}',
        'body': response.body,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Updates booking status only (convenience wrapper).
  Future<Map<String, dynamic>> updateBookingStatus(
    String bid,
    String newStatus,
  ) =>
      patchBooking(bid, status: newStatus);

  // ── WebSocket: Agent Stream ───────────────────────────────────────────────

  /// Connects to /ws/agent-stream and returns a stream of real-time
  /// agent reasoning events (THINK / ACT / OBSERVE / completed).
  ///
  /// Call [WebSocketClient.send] on the returned client to pass the query.
  /// Call [WebSocketClient.disconnect] on dispose to close cleanly.
  Stream<Map<String, dynamic>> connectAgentStream(WebSocketClient client) {
    return client.connect(ApiEndpoints.wsAgentStream);
  }

  /// Connects to the legacy /ws/trace/{sessionId} endpoint.
  Stream<Map<String, dynamic>> connectTraceStream(
    WebSocketClient client,
    String sessionId,
  ) {
    return client.connect(ApiEndpoints.wsTrace(sessionId));
  }

  // ── Legacy: createBooking ────────────────────────────────────────────────

  /// POST /api/booking/create — legacy endpoint kept for compatibility.
  Future<Map<String, dynamic>> createBooking(
    BookingCreateRequest request,
  ) async {
    return _client.post(ApiEndpoints.bookingCreate, request.toJson());
  }
}

/// Global singleton — import this wherever you need backend access.
final ApiService apiService = ApiService();
