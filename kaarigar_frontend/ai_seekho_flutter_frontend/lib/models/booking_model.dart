enum BookingStatus { active, completed, cancelled }

class Booking {
  const Booking({
    required this.id,
    required this.providerName,
    required this.service,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.status,
    this.canTrack = false,
    this.providerRating = 4.8,
    this.providerInitials = '',
    this.shortDate = '',
    this.timePill = '',
  });

  final String id;
  final String providerName;
  final String service;
  final String date;
  final String time;
  final String location;
  final String price;
  final BookingStatus status;
  final bool canTrack;
  final double providerRating;
  final String providerInitials;
  /// e.g. "May 17" on completed cards.
  final String shortDate;
  /// e.g. "Aaj 2:00 PM" pill on active cards.
  final String timePill;

  String get initials =>
      providerInitials.isNotEmpty
          ? providerInitials
          : providerName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();

  /// Maps a Firestore/backend booking document to [Booking].
  ///
  /// Handles both camelCase and snake_case field names defensively.
  factory Booking.fromJson(Map<String, dynamic> json) {
    // Resolve booking ID from multiple possible field names.
    final id = (json['bid'] ?? json['booking_id'] ?? json['id'] ?? '').toString();

    // Provider name may come from a nested map or a flat field.
    final providerName =
        (json['provider_name'] ?? json['providerName'] ?? 'Unknown Provider')
            .toString();

    // Service type.
    final service =
        (json['service_type'] ?? json['service'] ?? 'Service').toString();

    // Scheduled time — may be an ISO-8601 string.
    final rawTime =
        (json['scheduled_time'] ?? json['date'] ?? '').toString();
    String date = rawTime;
    String time = '';
    if (rawTime.contains('T')) {
      final parts = rawTime.split('T');
      date = parts[0];
      time = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
    }

    // Location address mapping: check nested location map or fallbacks.
    final locRaw = json['location'];
    final location = (locRaw is Map)
        ? (locRaw['address'] ?? locRaw['area'] ?? '').toString()
        : (json['location_address'] ?? json['location'] ?? '').toString();

    // Price — may be inside a price_quote map.
    String price = 'PKR —';
    final priceQuote = json['price_quote'];
    if (priceQuote is Map) {
      final nestedQuote = priceQuote['quote'];
      final Map<String, dynamic> breakdown = (nestedQuote is Map)
          ? ((nestedQuote['quote'] is Map) ? Map<String, dynamic>.from(nestedQuote['quote']) : Map<String, dynamic>.from(nestedQuote))
          : Map<String, dynamic>.from(priceQuote);

      final total = breakdown['total_pkr'] ?? breakdown['total'] ?? breakdown['amount'];
      final currency = breakdown['currency'] ?? 'PKR';
      if (total != null) {
        price = '$currency $total';
      }
    } else if (json['price'] != null) {
      price = json['price'].toString();
    }

    // Status.
    final rawStatus = (json['status'] ?? 'active').toString().toLowerCase();
    BookingStatus status;
    switch (rawStatus) {
      case 'completed':
        status = BookingStatus.completed;
        break;
      case 'cancelled':
      case 'canceled':
        status = BookingStatus.cancelled;
        break;
      default:
        status = BookingStatus.active;
    }

    // Rating.
    final rating = (json['provider_rating'] ?? json['rating'] ?? 4.8);

    return Booking(
      id: id,
      providerName: providerName,
      service: service,
      date: date,
      time: time,
      location: location,
      price: price,
      status: status,
      providerRating: (rating as num).toDouble(),
      canTrack: status == BookingStatus.active,
      shortDate: date,
      timePill: time.isNotEmpty ? 'Aaj $time' : '',
    );
  }
}
