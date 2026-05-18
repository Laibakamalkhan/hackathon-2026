class MatchRequest {
  final String query;
  final double lat;
  final double lng;
  final String sessionId;

  MatchRequest({
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

  BookingCreateRequest({
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
