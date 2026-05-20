import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_seekho/core/network/api_service.dart';
import 'package:ai_seekho/models/booking_model.dart';
import 'package:ai_seekho/services/mock_data_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class BookingState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  const BookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  BookingState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
    bool? isOffline,
    bool clearError = false,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  /// Loads all bookings for [userId] from the backend.
  ///
  /// Falls back to [MockDataService.bookings] when the backend is unreachable,
  /// and marks [BookingState.isOffline] = true so the UI can show a banner.
  Future<void> loadBookings(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await apiService.getUserBookings(userId);

      // The backend returns either:
      //   { "bookings": [ {...}, ... ] }   or
      //   [ {...}, ... ]  (wrapped under "data" by HttpClient)
      List<dynamic> raw = [];
      if (response.containsKey('bookings')) {
        raw = response['bookings'] as List<dynamic>;
      } else if (response.containsKey('data') && response['data'] is List) {
        raw = response['data'] as List<dynamic>;
      }

      final bookings = raw
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        bookings: bookings,
        isOffline: false,
      );
    } catch (_) {
      // Backend unreachable → serve mock data as offline fallback.
      state = state.copyWith(
        isLoading: false,
        bookings: List<Booking>.from(MockDataService.bookings),
        isOffline: true,
        error: 'Offline mode — showing cached data',
      );
    }
  }

  /// Updates a single booking's status via PATCH and refreshes the list.
  Future<void> updateStatus(String bid, String newStatus) async {
    try {
      await apiService.updateBookingStatus(bid, newStatus);
      // Optimistically update the local list.
      final updated = state.bookings.map((b) {
        if (b.id != bid) return b;
        return Booking(
          id: b.id,
          providerName: b.providerName,
          service: b.service,
          date: b.date,
          time: b.time,
          location: b.location,
          price: b.price,
          status: _parseStatus(newStatus),
          canTrack: b.canTrack,
          providerRating: b.providerRating,
          providerInitials: b.providerInitials,
          shortDate: b.shortDate,
          timePill: b.timePill,
        );
      }).toList();
      state = state.copyWith(bookings: updated);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update status: ${e.toString()}');
    }
  }

  BookingStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.active;
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, BookingState>(
  (ref) => BookingNotifier(),
);
