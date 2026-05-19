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
}
