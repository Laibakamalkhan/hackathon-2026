import '../../matching/models/matching_models.dart';

class BookingModel {
  final String bid;
  final String userId;
  final String providerId;
  final String serviceType;
  final String status;
  final String scheduledTime;
  final String locationAddress;
  final double lat;
  final double lng;
  final PriceQuoteModel? priceQuote;
  final String intentRaw;
  final Map<String, dynamic> intentParsed;
  final String createdAt;
  final String updatedAt;

  BookingModel({
    required this.bid,
    required this.userId,
    required this.providerId,
    required this.serviceType,
    required this.status,
    required this.scheduledTime,
    required this.locationAddress,
    required this.lat,
    required this.lng,
    this.priceQuote,
    required this.intentRaw,
    required this.intentParsed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] ?? {};
    return BookingModel(
      bid: json['bid'] ?? '',
      userId: json['user_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      serviceType: json['service_type'] ?? '',
      status: json['status'] ?? 'pending',
      scheduledTime: json['scheduled_time'] ?? '',
      locationAddress: loc['address'] ?? '',
      lat: (loc['lat'] ?? 0.0) as double,
      lng: (loc['lng'] ?? 0.0) as double,
      priceQuote: json['price_quote'] != null
          ? PriceQuoteModel.fromJson(json['price_quote'])
          : null,
      intentRaw: json['intent_raw'] ?? '',
      intentParsed: Map<String, dynamic>.from(json['intent_parsed'] ?? {}),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "provider_id": providerId,
      "service_type": serviceType,
      "scheduled_time": scheduledTime,
      "location_address": locationAddress,
      "lat": lat,
      "lng": lng,
      "price_quote": priceQuote != null
          ? {
              "base_rate_pkr": priceQuote!.baseRatePkr,
              "visit_fee": priceQuote!.visitFee,
              "distance_fee": priceQuote!.distanceFee,
              "urgency_surcharge": priceQuote!.urgencySurcharge,
              "complexity_premium": priceQuote!.complexityPremium,
              "loyalty_discount": priceQuote!.loyaltyDiscount,
              "total_pkr": priceQuote!.totalPkr,
              "breakdown_reasoning": priceQuote!.breakdownReasoning,
            }
          : {},
      "intent_raw": intentRaw,
      "intent_parsed": intentParsed,
    };
  }
}
