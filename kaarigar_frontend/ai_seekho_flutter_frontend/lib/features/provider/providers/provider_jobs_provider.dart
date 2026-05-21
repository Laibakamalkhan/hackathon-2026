import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';

/// Demo provider id — first provider in seed data (Ali AC Services).
const defaultProviderId = 'P001';

class ProviderDashboardState {
  final Map<String, dynamic>? dashboard;
  final List<Map<String, dynamic>> bookings;
  final bool isLoading;
  final String? error;

  const ProviderDashboardState({
    this.dashboard,
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  ProviderDashboardState copyWith({
    Map<String, dynamic>? dashboard,
    List<Map<String, dynamic>>? bookings,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProviderDashboardState(
      dashboard: dashboard ?? this.dashboard,
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProviderDashboardNotifier extends StateNotifier<ProviderDashboardState> {
  ProviderDashboardNotifier() : super(const ProviderDashboardState());

  Future<void> load(String providerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dash = await apiService.getProviderDashboard(providerId);
      final bookings = await apiService.getProviderBookings(providerId);
      final list = (bookings['bookings'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      state = ProviderDashboardState(
        isLoading: false,
        dashboard: dash,
        bookings: list,
      );
    } catch (e) {
      state = ProviderDashboardState(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateJobStatus(String bid, String status) async {
    try {
      await apiService.providerUpdateBookingStatus(bid, status);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final providerDashboardNotifierProvider =
    StateNotifierProvider<ProviderDashboardNotifier, ProviderDashboardState>(
  (ref) => ProviderDashboardNotifier(),
);

final selectedProviderJobIdProvider = StateProvider<String?>((ref) => null);
