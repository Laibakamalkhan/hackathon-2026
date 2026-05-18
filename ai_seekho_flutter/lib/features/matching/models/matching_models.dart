class TraceStepModel {
  final int step;
  final String agent;
  final String action;
  final String reasoning;
  final double confidence;
  final int latencyMs;
  final List<String> toolsUsed;
  final String timestamp;

  TraceStepModel({
    required this.step,
    required this.agent,
    required this.action,
    required this.reasoning,
    required this.confidence,
    required this.latencyMs,
    required this.toolsUsed,
    required this.timestamp,
  });

  factory TraceStepModel.fromJson(Map<String, dynamic> json) {
    return TraceStepModel(
      step: json['step'] ?? 0,
      agent: json['agent'] ?? '',
      action: json['action'] ?? '',
      reasoning: json['reasoning'] ?? '',
      confidence: (json['confidence'] ?? 0.0) as double,
      latencyMs: json['latency_ms'] ?? 0,
      toolsUsed: List<String>.from(json['tools_used'] ?? []),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ProviderModel {
  final String pid;
  final String name;
  final String area;
  final double lat;
  final double lng;
  final double distanceKm;
  final double matchScore;
  final List<String> specializations;
  final double rating;
  final int experienceYears;
  final int baseRatePkr;
  final double cancellationRate;

  ProviderModel({
    required this.pid,
    required this.name,
    required this.area,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.matchScore,
    required this.specializations,
    required this.rating,
    required this.experienceYears,
    required this.baseRatePkr,
    required this.cancellationRate,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] ?? {};
    return ProviderModel(
      pid: json['pid'] ?? '',
      name: json['name'] ?? '',
      area: loc['area'] ?? '',
      lat: (loc['lat'] ?? 0.0) as double,
      lng: (loc['lng'] ?? 0.0) as double,
      distanceKm: (json['distance_km'] ?? 0.0) as double,
      matchScore: (json['match_score'] ?? 0.0) as double,
      specializations: List<String>.from(
        json['specialization'] ?? json['specializations'] ?? [],
      ),
      rating: (json['rating'] ?? 0.0) as double,
      experienceYears: json['experience_years'] ?? 0,
      baseRatePkr: json['base_rate_pkr'] ?? 0,
      cancellationRate: (json['cancellation_rate'] ?? 0.0) as double,
    );
  }
}

class PriceQuoteModel {
  final int baseRatePkr;
  final int visitFee;
  final int distanceFee;
  final int urgencySurcharge;
  final int complexityPremium;
  final int loyaltyDiscount;
  final int totalPkr;
  final String breakdownReasoning;

  PriceQuoteModel({
    required this.baseRatePkr,
    required this.visitFee,
    required this.distanceFee,
    required this.urgencySurcharge,
    required this.complexityPremium,
    required this.loyaltyDiscount,
    required this.totalPkr,
    required this.breakdownReasoning,
  });

  factory PriceQuoteModel.fromJson(Map<String, dynamic> json) {
    final quote = json['quote'] ?? json;
    return PriceQuoteModel(
      baseRatePkr: quote['base_rate_pkr'] ?? 0,
      visitFee: quote['visit_fee'] ?? 0,
      distanceFee: quote['distance_fee'] ?? 0,
      urgencySurcharge: quote['urgency_surcharge'] ?? 0,
      complexityPremium: quote['complexity_premium'] ?? 0,
      loyaltyDiscount: quote['loyalty_discount'] ?? 0,
      totalPkr: quote['total_pkr'] ?? 0,
      breakdownReasoning: quote['breakdown_reasoning'] ?? '',
    );
  }
}

class MatchResultModel {
  final String traceId;
  final List<ProviderModel> matchingProviders;
  final PriceQuoteModel? primaryQuote;
  final List<TraceStepModel> steps;
  final int totalLatencyMs;

  MatchResultModel({
    required this.traceId,
    required this.matchingProviders,
    this.primaryQuote,
    required this.steps,
    required this.totalLatencyMs,
  });

  factory MatchResultModel.fromJson(Map<String, dynamic> json) {
    final list = json['matching_providers'] as List? ?? [];
    final stepsList = json['steps'] as List? ?? [];
    return MatchResultModel(
      traceId: json['trace_id'] ?? '',
      matchingProviders: list
          .map((item) => ProviderModel.fromJson(item))
          .toList(),
      primaryQuote: json['primary_quote'] != null
          ? PriceQuoteModel.fromJson(json['primary_quote'])
          : null,
      steps: stepsList.map((item) => TraceStepModel.fromJson(item)).toList(),
      totalLatencyMs: json['total_latency_ms'] ?? 0,
    );
  }
}
