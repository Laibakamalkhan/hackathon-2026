import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../models/booking_model.dart';

class BookingState {
  final bool isLoading;
  final String? error;
  final BookingModel? currentBooking;

  BookingState({this.isLoading = false, this.error, this.currentBooking});

  BookingState copyWith({
    bool? isLoading,
    String? error,
    BookingModel? currentBooking,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentBooking: currentBooking ?? this.currentBooking,
    );
  }
}

class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() {
    return BookingState();
  }

  Future<bool> createServiceBooking(BookingModel booking) async {
    final repository = ref.read(bookingRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final created = await repository.createBooking(booking);
      state = state.copyWith(isLoading: false, currentBooking: created);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearBookingState() {
    state = BookingState();
  }
}

final bookingStateProvider = NotifierProvider<BookingNotifier, BookingState>(
  () {
    return BookingNotifier();
  },
);
