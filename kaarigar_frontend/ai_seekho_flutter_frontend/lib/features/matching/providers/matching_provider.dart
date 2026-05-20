import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_seekho/core/network/api_service.dart';
import 'package:ai_seekho/models/provider_model.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class MatchingState {
  /// The full raw response from /api/v1/agent/coordinate.
  /// Screens like ProviderRankingScreen and PriceBreakdownScreen read from this.
  final Map<String, dynamic>? coordinatorResult;

  /// Convenience list of providers parsed from [coordinatorResult].
  final List<ServiceProvider> providers;

  /// The quote map from the coordinator response.
  final Map<String, dynamic>? quote;

  /// The handoff payload needed to call agentExecute.
  final Map<String, dynamic>? handoff;

  final bool isLoading;
  final String? error;

  const MatchingState({
    this.coordinatorResult,
    this.providers = const [],
    this.quote,
    this.handoff,
    this.isLoading = false,
    this.error,
  });

  MatchingState copyWith({
    Map<String, dynamic>? coordinatorResult,
    List<ServiceProvider>? providers,
    Map<String, dynamic>? quote,
    Map<String, dynamic>? handoff,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MatchingState(
      coordinatorResult: coordinatorResult ?? this.coordinatorResult,
      providers: providers ?? this.providers,
      quote: quote ?? this.quote,
      handoff: handoff ?? this.handoff,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class MatchingNotifier extends StateNotifier<MatchingState> {
  MatchingNotifier() : super(const MatchingState());

  /// Calls /api/v1/agent/coordinate via HTTP and stores the full result.
  ///
  /// After this resolves, [MatchingState.providers] and [MatchingState.quote]
  /// are populated and ready for ProviderRankingScreen / PriceBreakdownScreen.
  Future<void> coordinate({
    required String query,
    required double lat,
    required double lng,
    String sessionId = 'session-default',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await apiService.agentCoordinate(
        query: query,
        lat: lat,
        lng: lng,
        sessionId: sessionId,
      );

      // Parse providers list from the coordinator response.
      // The backend returns either result['providers'] or result['matching_providers'].
      final rawProviders = (result['providers'] ??
          result['matching_providers'] ??
          []) as List<dynamic>;

      final providers = rawProviders
          .map((p) => ServiceProvider.fromJson(p as Map<String, dynamic>))
          .toList();

      // Quote is at result['quote'] or result['price_quote'].
      final quote = (result['quote'] ?? result['price_quote'])
          as Map<String, dynamic>?;

      // Handoff payload for agentExecute.
      final handoff = result['handoff'] as Map<String, dynamic>?;

      state = state.copyWith(
        isLoading: false,
        coordinatorResult: result,
        providers: providers,
        quote: quote,
        handoff: handoff,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Stores the completed WebSocket event's payload directly.
  ///
  /// Called by [ChatActiveScreen] when the WS "completed" event arrives,
  /// so that ProviderRankingScreen can immediately use the data.
  void storeCoordinatorResult(Map<String, dynamic> result) {
    final rawProviders = (result['providers'] ??
        result['matching_providers'] ??
        []) as List<dynamic>;

    final providers = rawProviders
        .map((p) => ServiceProvider.fromJson(p as Map<String, dynamic>))
        .toList();

    final quote = (result['quote'] ?? result['price_quote'])
        as Map<String, dynamic>?;

    final handoff = result['handoff'] as Map<String, dynamic>?;

    state = state.copyWith(
      coordinatorResult: result,
      providers: providers,
      quote: quote,
      handoff: handoff,
      isLoading: false,
      clearError: true,
    );
  }

  void reset() => state = const MatchingState();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final matchingNotifierProvider =
    StateNotifierProvider<MatchingNotifier, MatchingState>(
  (ref) => MatchingNotifier(),
);
