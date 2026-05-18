class ApiEndpoints {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator or web
  static const String baseHttpUrl = "http://10.0.2.2:8000";
  static const String baseWsUrl = "ws://10.0.2.2:8000";

  // HTTP endpoints
  static const String match = "$baseHttpUrl/api/match";
  static const String providers = "$baseHttpUrl/api/providers";
  static const String bookingCreate = "$baseHttpUrl/api/booking/create";
  static const String disputeCreate = "$baseHttpUrl/api/dispute/create";
  static String trace(String traceId) => "$baseHttpUrl/api/trace/$traceId";

  // WebSocket endpoints
  static String wsTrace(String sessionId) => "$baseWsUrl/ws/trace/$sessionId";
}
