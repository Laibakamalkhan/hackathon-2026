import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_seekho/core/network/api_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class DisputeState {
  /// The full raw response from /api/v1/agent/resolve.
  final Map<String, dynamic>? resolution;
  final bool isLoading;
  final String? error;

  // Stored request fields for retry mechanism
  final String? lastBookingId;
  final String? lastDisputeType;
  final String? lastDescription;
  final String? lastUserId;

  const DisputeState({
    this.resolution,
    this.isLoading = false,
    this.error,
    this.lastBookingId,
    this.lastDisputeType,
    this.lastDescription,
    this.lastUserId,
  });

  DisputeState copyWith({
    Map<String, dynamic>? resolution,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? lastBookingId,
    String? lastDisputeType,
    String? lastDescription,
    String? lastUserId,
  }) {
    return DisputeState(
      resolution: resolution ?? this.resolution,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastBookingId: lastBookingId ?? this.lastBookingId,
      lastDisputeType: lastDisputeType ?? this.lastDisputeType,
      lastDescription: lastDescription ?? this.lastDescription,
      lastUserId: lastUserId ?? this.lastUserId,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DisputeNotifier extends StateNotifier<DisputeState> {
  DisputeNotifier() : super(const DisputeState());

  /// Calls /api/v1/agent/resolve via the GuardianAgent.
  Future<bool> resolve({
    required String bookingId,
    required String disputeType,
    required String description,
    String userId = 'user_demo_001',
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      lastBookingId: bookingId,
      lastDisputeType: disputeType,
      lastDescription: description,
      lastUserId: userId,
    );
    try {
      final result = await apiService.resolveDispute(
        bookingId: bookingId,
        disputeType: disputeType,
        description: description,
        userId: userId,
      );
      state = state.copyWith(isLoading: false, resolution: result);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const DisputeState();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final disputeNotifierProvider =
    StateNotifierProvider<DisputeNotifier, DisputeState>(
  (ref) => DisputeNotifier(),
);

