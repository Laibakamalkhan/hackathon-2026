import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_seekho/core/network/api_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class DisputeState {
  /// The full raw response from /api/v1/agent/resolve.
  /// DisputeResolutionScreen reads resolution_type, refund_amount, explanation.
  final Map<String, dynamic>? resolution;

  final bool isLoading;
  final String? error;

  const DisputeState({
    this.resolution,
    this.isLoading = false,
    this.error,
  });

  DisputeState copyWith({
    Map<String, dynamic>? resolution,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DisputeState(
      resolution: resolution ?? this.resolution,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DisputeNotifier extends StateNotifier<DisputeState> {
  DisputeNotifier() : super(const DisputeState());

  /// Calls /api/v1/agent/resolve via the GuardianAgent.
  ///
  /// On success, [DisputeState.resolution] contains:
  /// ```json
  /// {
  ///   "resolution_type": "full_refund" | "partial_refund" | "no_refund",
  ///   "refund_amount":   1200,
  ///   "explanation":     "Provider did not show up within 2 hours..."
  /// }
  /// ```
  Future<bool> resolve({
    required String bookingId,
    required String disputeType,
    required String description,
    String userId = 'user_demo_001',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
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
