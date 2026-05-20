class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.name,
    required this.service,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.price,
    required this.matchScore,
    required this.eta,
    this.verified = true,
    this.badges = const [],
  });

  final String id;
  final String name;
  final String service;
  final double rating;
  final int reviews;
  final String distance;
  final String price;
  final int matchScore;
  final String eta;
  final bool verified;
  final List<String> badges;

  /// Maps a backend provider document (from /api/providers or coordinator
  /// response) to [ServiceProvider].
  ///
  /// Field name variations:
  /// - reviews:    `total_reviews` | `reviews`
  /// - distance:   `distance_km` (numeric) | `distance` (string)
  /// - price:      `price_range` | `price`
  /// - matchScore: `match_score` | `matchScore`
  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    // Distance — may be a number (km) or a pre-formatted string.
    final rawDistance = json['distance_km'] ?? json['distance'];
    String distance;
    if (rawDistance is num) {
      distance = '${rawDistance.toStringAsFixed(1)} km';
    } else {
      distance = (rawDistance ?? '—').toString();
    }

    // Match score — may be a double, int, or absent.
    final rawScore = json['match_score'] ?? json['matchScore'] ?? 80;
    final matchScore = (rawScore as num).round();

    // Reviews.
    final reviews =
        ((json['total_reviews'] ?? json['reviews'] ?? 0) as num).toInt();

    // Rating.
    final rating =
        ((json['rating'] ?? 4.5) as num).toDouble();

    // Price.
    final price = (json['price_range'] ?? json['price'] ?? 'PKR —').toString();

    // ETA.
    final eta = (json['eta'] ?? '—').toString();

    // Verified / badges.
    final verified = json['verified'] as bool? ?? json['is_verified'] as bool? ?? true;
    final rawBadges = json['badges'] as List<dynamic>? ?? const [];
    final badges = rawBadges.map((b) => b.toString()).toList();

    return ServiceProvider(
      id: (json['id'] ?? json['provider_id'] ?? '').toString(),
      name: (json['name'] ?? json['provider_name'] ?? 'Unknown').toString(),
      service: (json['service'] ?? json['service_type'] ?? 'Service').toString(),
      rating: rating,
      reviews: reviews,
      distance: distance,
      price: price,
      matchScore: matchScore,
      eta: eta,
      verified: verified,
      badges: badges,
    );
  }
}
