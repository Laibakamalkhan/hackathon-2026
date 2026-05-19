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
}
