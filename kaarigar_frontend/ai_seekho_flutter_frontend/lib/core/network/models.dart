/// Request model for the legacy `/api/match` endpoint.
class MatchRequest {
  final String query;
  final double lat;
  final double lng;
  final String sessionId;

  const MatchRequest({
    required this.query,
    required this.lat,
    required this.lng,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'lat': lat,
        'lng': lng,
        'session_id': sessionId,
      };
}

/// Request model for `/api/v1/agent/coordinate`.
class CoordinateRequest {
  final String query;
  final double lat;
  final double lng;
  final String sessionId;
  final List<Map<String, dynamic>>? conversationHistory;

  const CoordinateRequest({
    required this.query,
    required this.lat,
    required this.lng,
    this.sessionId = 'session-default',
    this.conversationHistory,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'query': query,
      'lat': lat,
      'lng': lng,
      'session_id': sessionId,
    };
    if (conversationHistory != null) {
      map['conversation_history'] = conversationHistory;
    }
    return map;
  }
}

/// Request model for the legacy `/api/booking/create` endpoint.
class BookingCreateRequest {
  final String userId;
  final String providerId;
  final String serviceType;
  final String scheduledTime;
  final String locationAddress;
  final double lat;
  final double lng;
  final Map<String, dynamic> priceQuote;
  final String intentRaw;
  final Map<String, dynamic> intentParsed;

  const BookingCreateRequest({
    required this.userId,
    required this.providerId,
    required this.serviceType,
    required this.scheduledTime,
    required this.locationAddress,
    required this.lat,
    required this.lng,
    required this.priceQuote,
    required this.intentRaw,
    required this.intentParsed,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'provider_id': providerId,
        'service_type': serviceType,
        'scheduled_time': scheduledTime,
        'location_address': locationAddress,
        'lat': lat,
        'lng': lng,
        'price_quote': priceQuote,
        'intent_raw': intentRaw,
        'intent_parsed': intentParsed,
      };
}
