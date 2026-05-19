class ApiEndpoints {
  // Platform-aware base URL
  // Use 10.0.2.2 for Android Emulator (routes to host machine localhost)
  // Use 127.0.0.1 for iOS Simulator or Desktop/Web
  static const bool _isAndroidEmulator =
      bool.fromEnvironment('ANDROID_EMULATOR', defaultValue: false);

  static String get baseHttpUrl =>
      _isAndroidEmulator ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';

  static String get baseWsUrl =>
      _isAndroidEmulator ? 'ws://10.0.2.2:8000' : 'ws://127.0.0.1:8000';

  // ── Legacy HTTP endpoints (unchanged) ──
  static String get match => '$baseHttpUrl/api/match';
  static String get providers => '$baseHttpUrl/api/providers';
  static String get bookingCreate => '$baseHttpUrl/api/booking/create';
  static String get disputeCreate => '$baseHttpUrl/api/dispute/create';
  static String trace(String traceId) => '$baseHttpUrl/api/trace/$traceId';

  // ── Legacy WebSocket endpoint (unchanged) ──
  static String wsTrace(String sessionId) =>
      '$baseWsUrl/ws/trace/$sessionId';

  // ── NEW: v1 Agent endpoints ──
  static String get agentCoordinate => '$baseHttpUrl/api/v1/agent/coordinate';
  static String get agentExecute => '$baseHttpUrl/api/v1/agent/execute';
  static String get agentResolve => '$baseHttpUrl/api/v1/agent/resolve';
  static String get feedbackSubmit => '$baseHttpUrl/api/v1/feedback/submit';
  static String get getBookings => '$baseHttpUrl/api/v1/bookings';
  static String updateBookingStatus(String bid) =>
      '$baseHttpUrl/api/v1/booking/$bid/status';

  // ── NEW: v1 Agent WebSocket ──
  static String get wsAgentStream => '$baseWsUrl/ws/agent-stream';
}
