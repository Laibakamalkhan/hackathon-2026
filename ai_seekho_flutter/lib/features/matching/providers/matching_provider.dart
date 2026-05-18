import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../models/matching_models.dart';

class MatchingState {
  final bool isLoading;
  final String? error;
  final String? traceId;
  final List<ProviderModel> matchingProviders;
  final PriceQuoteModel? primaryQuote;
  final List<TraceStepModel> steps;
  final String liveStatusMessage;

  MatchingState({
    this.isLoading = false,
    this.error,
    this.traceId,
    this.matchingProviders = const [],
    this.primaryQuote,
    this.steps = const [],
    this.liveStatusMessage = '',
  });

  MatchingState copyWith({
    bool? isLoading,
    String? error,
    String? traceId,
    List<ProviderModel>? matchingProviders,
    PriceQuoteModel? primaryQuote,
    List<TraceStepModel>? steps,
    String? liveStatusMessage,
  }) {
    return MatchingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      traceId: traceId ?? this.traceId,
      matchingProviders: matchingProviders ?? this.matchingProviders,
      primaryQuote: primaryQuote ?? this.primaryQuote,
      steps: steps ?? this.steps,
      liveStatusMessage: liveStatusMessage ?? this.liveStatusMessage,
    );
  }
}

class MatchingNotifier extends Notifier<MatchingState> {
  StreamSubscription? _streamSubscription;

  @override
  MatchingState build() {
    ref.onDispose(() {
      _streamSubscription?.cancel();
      ref.read(matchingRepositoryProvider).disconnectWs();
    });
    return MatchingState();
  }

  Future<void> runRestMatch({
    required String query,
    required double lat,
    required double lng,
    required String sessionId,
  }) async {
    final repository = ref.read(matchingRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await repository.postMatchRequest(
        query: query,
        lat: lat,
        lng: lng,
        sessionId: sessionId,
      );
      state = state.copyWith(
        isLoading: false,
        traceId: result.traceId,
        matchingProviders: result.matchingProviders,
        primaryQuote: result.primaryQuote,
        steps: result.steps,
        liveStatusMessage: "Orchestration Completed Successfully!",
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void startReasoningStream({
    required String query,
    required double lat,
    required double lng,
    required String sessionId,
  }) {
    final repository = ref.read(matchingRepositoryProvider);
    state = state.copyWith(
      isLoading: true,
      error: null,
      steps: [],
      matchingProviders: [],
      primaryQuote: null,
      liveStatusMessage: "Connecting to WebSocket orchestrator...",
    );

    _streamSubscription?.cancel();

    final stream = repository.listenToReasoningStream(sessionId);

    _streamSubscription = stream.listen(
      (message) {
        final event = message['event'] ?? '';

        if (event == 'orchestration_started') {
          state = state.copyWith(
            liveStatusMessage:
                message['message'] ?? 'Initializing reasoning glass...',
          );
        } else if (event == 'step_completed') {
          final stepMap = message['step'];
          if (stepMap != null) {
            final step = TraceStepModel.fromJson(stepMap);
            final updatedSteps = List<TraceStepModel>.from(state.steps)
              ..add(step);
            state = state.copyWith(
              steps: updatedSteps,
              liveStatusMessage:
                  "Agent [${step.agent}] finalized: ${step.action}",
            );
          }
        } else if (event == 'orchestration_completed') {
          final traceId = message['trace_id'] ?? '';
          final providersList = message['matching_providers'] as List? ?? [];
          final quoteMap = message['primary_quote'];
          final stepsList = message['steps'] as List? ?? [];

          final providers = providersList
              .map((item) => ProviderModel.fromJson(item))
              .toList();
          final quote = quoteMap != null
              ? PriceQuoteModel.fromJson(quoteMap)
              : null;
          final steps = stepsList
              .map((item) => TraceStepModel.fromJson(item))
              .toList();

          state = state.copyWith(
            isLoading: false,
            traceId: traceId,
            matchingProviders: providers,
            primaryQuote: quote,
            steps: steps,
            liveStatusMessage: "Full Agent Trace Coordinated and Saved!",
          );
          repository.disconnectWs();
        } else if (event == 'error') {
          state = state.copyWith(
            isLoading: false,
            error: message['message'] ?? 'Stream computation failure',
          );
          repository.disconnectWs();
        }
      },
      onError: (err) {
        state = state.copyWith(
          isLoading: false,
          error: "WebSocket Error: ${err.toString()}",
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      repository.sendWsQuery(query, lat, lng);
    });
  }
}

final matchingStateProvider = NotifierProvider<MatchingNotifier, MatchingState>(
  () {
    return MatchingNotifier();
  },
);
