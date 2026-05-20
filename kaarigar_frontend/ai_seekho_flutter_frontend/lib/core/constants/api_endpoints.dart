/// All backend URL constants for KARIGAR.
///
/// Pass `--dart-define=ANDROID_EMULATOR=true` when running on Android Emulator
/// so that 10.0.2.2 is used instead of 127.0.0.1.
class ApiEndpoints {
  // ── Platform-aware host ───────────────────────────────────────────────────
  static const bool _isAndroidEmulator =
      bool.fromEnvironment('ANDROID_EMULATOR', defaultValue: false);

  static String get baseHttpUrl =>
      _isAndroidEmulator ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';

  static String get baseWsUrl =>
      _isAndroidEmulator ? 'ws://10.0.2.2:8000' : 'ws://127.0.0.1:8000';

  // ── Legacy HTTP endpoints (kept for completeness) ─────────────────────────
  static String get match        => '$baseHttpUrl/api/match';
  static String get providers    => '$baseHttpUrl/api/providers';
  static String get bookingCreate => '$baseHttpUrl/api/booking/create';
  static String get disputeCreate => '$baseHttpUrl/api/dispute/create';

  // ── v1 Agent HTTP endpoints ───────────────────────────────────────────────
  static String get agentCoordinate => '$baseHttpUrl/api/v1/agent/coordinate';
  static String get agentExecute    => '$baseHttpUrl/api/v1/agent/execute';
  static String get agentResolve    => '$baseHttpUrl/api/v1/agent/resolve';
  static String get feedbackSubmit  => '$baseHttpUrl/api/v1/feedback/submit';
  static String get getBookings     => '$baseHttpUrl/api/v1/bookings';

  /// PATCH /api/v1/booking/{bid}/status
  static String updateBookingStatus(String bid) =>
      '$baseHttpUrl/api/v1/booking/$bid/status';

  // ── WebSocket endpoints ───────────────────────────────────────────────────
  /// Real-time agent reasoning stream (THINK / ACT / OBSERVE events).
  static String get wsAgentStream => '$baseWsUrl/ws/agent-stream';

  /// Legacy trace stream.
  static String wsTrace(String sessionId) => '$baseWsUrl/ws/trace/$sessionId';
}
