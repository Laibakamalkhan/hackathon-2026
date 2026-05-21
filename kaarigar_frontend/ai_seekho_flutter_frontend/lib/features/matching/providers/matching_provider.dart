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

  /// Parsed intent entities from coordinator.
  final Map<String, dynamic>? extractedFields;

  /// Confidence score of parsed intent.
  final double? confidence;

  /// Proposed next routing action.
  final String? action;

  final bool isLoading;
  final String? error;

  const MatchingState({
    this.coordinatorResult,
    this.providers = const [],
    this.quote,
    this.handoff,
    this.extractedFields,
    this.confidence,
    this.action,
    this.isLoading = false,
    this.error,
  });

  MatchingState copyWith({
    Map<String, dynamic>? coordinatorResult,
    List<ServiceProvider>? providers,
    Map<String, dynamic>? quote,
    Map<String, dynamic>? handoff,
    Map<String, dynamic>? extractedFields,
    double? confidence,
    String? action,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MatchingState(
      coordinatorResult: coordinatorResult ?? this.coordinatorResult,
      providers: providers ?? this.providers,
      quote: quote ?? this.quote,
      handoff: handoff ?? this.handoff,
      extractedFields: extractedFields ?? this.extractedFields,
      confidence: confidence ?? this.confidence,
      action: action ?? this.action,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class MatchingNotifier extends StateNotifier<MatchingState> {
  MatchingNotifier() : super(const MatchingState());

  // ── Single normaliser ────────────────────────────────────────────────────

  /// Normalises any coordinator payload — HTTP response or WS "completed"
  /// event — into [MatchingState] fields and updates state atomically.
  ///
  /// Field mapping:
  ///
  /// | MatchingState field | Primary key        | Fallback key                     |
  /// |---------------------|--------------------|----------------------------------|
  /// | providers           | providers          | matching_providers               |
  /// | quote               | quote              | price_quote                      |
  /// | handoff             | handoff            | (none)                           |
  /// | extractedFields     | extracted_fields   | updated_state.extracted_fields   |
  /// | confidence          | confidence         | updated_state.confidence         |
  /// | action              | action             | (none)                           |
  /// | coordinatorResult   | raw map stored as-is for downstream screens            |
  void _applyCoordinatorPayload(Map<String, dynamic> raw) {
    // providers
    final rawProviders = (raw['providers'] ??
        raw['matching_providers'] ??
        <dynamic>[]) as List<dynamic>;
    final providers = rawProviders
        .map((p) => ServiceProvider.fromJson(p as Map<String, dynamic>))
        .toList();

    // quote
    final quote =
        (raw['quote'] ?? raw['price_quote']) as Map<String, dynamic>?;

    // handoff
    final handoff = raw['handoff'] as Map<String, dynamic>?;

    // extractedFields — top-level or nested under updated_state
    final extractedFields = (raw['extracted_fields'] ??
        (raw['updated_state'] as Map<String, dynamic>?)?['extracted_fields'])
        as Map<String, dynamic>?;

    // confidence — top-level or nested under updated_state
    final confidenceRaw = raw['confidence'] ??
        (raw['updated_state'] as Map<String, dynamic>?)?['confidence'];
    final double? confidence =
        confidenceRaw is num ? confidenceRaw.toDouble() : null;

    // action
    final action = raw['action'] as String?;

    state = state.copyWith(
      coordinatorResult: raw,
      providers: providers,
      quote: quote,
      handoff: handoff,
      extractedFields: extractedFields,
      confidence: confidence,
      action: action,
      isLoading: false,
      clearError: true,
    );
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Calls /api/v1/agent/coordinate via HTTP and normalises the response.
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
      _applyCoordinatorPayload(result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Stores the completed WebSocket event's payload directly.
  ///
  /// Called by [ChatActiveScreen] when the WS "completed" event arrives so that
  /// ProviderRankingScreen can immediately use the data. Delegates to the shared
  /// [_applyCoordinatorPayload] normaliser — no duplicate parse logic.
  void storeCoordinatorResult(Map<String, dynamic> result) {
    _applyCoordinatorPayload(result);
  }

  void updateHandoffProvider(ServiceProvider selected) {
    if (state.handoff == null) return;

    final handoffCopy = Map<String, dynamic>.from(state.handoff!);
    final fullContext = handoffCopy['full_context'] != null
        ? Map<String, dynamic>.from(handoffCopy['full_context'] as Map)
        : <String, dynamic>{};

    fullContext['provider_id'] = selected.id;

    // Find raw provider from coordinatorResult if possible
    final rawProviders = (state.coordinatorResult?['providers'] ??
        state.coordinatorResult?['matching_providers'] ??
        []) as List<dynamic>;

    Map<String, dynamic>? rawProviderMap;
    for (var p in rawProviders) {
      final m = p as Map<String, dynamic>;
      final pid = (m['pid'] ?? m['id'] ?? m['provider_id'] ?? '').toString();
      if (pid == selected.id) {
        rawProviderMap = m;
        break;
      }
    }

    if (rawProviderMap != null) {
      fullContext['provider'] = rawProviderMap;
    } else if (selected.rawJson.isNotEmpty) {
      fullContext['provider'] = selected.rawJson;
    } else {
      fullContext['provider'] = {
        'pid': selected.id,
        'name': selected.name,
        'service_categories': [selected.service],
        'base_rate_pkr': 500,
      };
    }

    handoffCopy['full_context'] = fullContext;
    handoffCopy['provider_id'] = selected.id;

    state = state.copyWith(handoff: handoffCopy);
  }

  void reset() => state = const MatchingState();

  /// Clears match results while keeping parsed intent for clarification flows.
  void clearForClarification() {
    state = MatchingState(
      coordinatorResult: state.coordinatorResult,
      extractedFields: state.extractedFields,
      confidence: state.confidence,
      action: 'ask_clarification',
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final matchingNotifierProvider =
    StateNotifierProvider<MatchingNotifier, MatchingState>(
  (ref) => MatchingNotifier(),
);
