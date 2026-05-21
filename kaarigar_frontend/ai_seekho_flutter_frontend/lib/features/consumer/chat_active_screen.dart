import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_durations.dart';
import '../../core/network/api_service.dart';
import '../../core/network/websocket_client.dart';
import '../../core/providers/app_providers.dart';
import '../../features/matching/providers/matching_provider.dart';
import '../../main.dart';
import '../../models/intent_display_model.dart';
import '../../models/user_role.dart';
import '../../routes/app_routes.dart';
import '../../widgets/ai_orb_logo.dart';
import '../../widgets/ai_pipeline_panel.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/intent_summary_card.dart';

class ChatActiveScreen extends ConsumerStatefulWidget {
  const ChatActiveScreen({super.key});

  @override
  ConsumerState<ChatActiveScreen> createState() => _ChatActiveScreenState();
}

class _ChatActiveScreenState extends ConsumerState<ChatActiveScreen> {
  int _stage = 0;
  double _progress = 0;
  bool _editingIntent = false;

  /// Set once in initState; reused by WS send + HTTP coordinate so both calls
  /// share the same session ID for backend traceability.
  late final String _sessionId;

  /// Non-null only when the HTTP fallback itself failed (backend online but
  /// both WS and HTTP errored). Shown as an error row in the pipeline panel.
  /// When this is set the timer is NOT started — we show a real error, not
  /// a fake progress animation.
  String? _httpErrorMessage;

  // Real-time WebSocket stream.
  Timer? _progressTimer;
  WebSocketClient? _wsClient;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  /// Most recent content from any WS trace event; shown as dynamic stage detail.
  String _lastTraceDetail = '';

  // ── Visual stage definitions ───────────────────────────────────────────────
  // Made a getter so _lastTraceDetail can update the first stage's detail text.
  List<AgentStage> get _stages => [
        AgentStage(
          label: 'Understanding request',
          detail: _lastTraceDetail.isNotEmpty
              ? _lastTraceDetail
              : 'Parsing your query…',
          color: AppColors.accentLavender,
          icon: Icons.psychology_outlined,
        ),
        AgentStage(
          label: 'Searching providers',
          detail: 'Scanning nearby technicians',
          color: AppColors.accentSand,
          icon: Icons.search,
        ),
        AgentStage(
          label: 'Ranking options',
          detail: 'Evaluating quality & price match',
          color: AppColors.warning,
          icon: Icons.trending_up,
        ),
        AgentStage(
          label: 'Checking availability',
          detail: 'Confirming open slots',
          color: AppColors.success,
          icon: Icons.event_available_outlined,
        ),
        AgentStage(
          label: 'Analysis complete',
          detail: 'Best matches found!',
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        ),
      ];

  // ── Dynamic intent tiles built from backend extracted_fields ──────────────
  List<IntentTileData> _buildTiles() {
    final matching = ref.read(matchingNotifierProvider);
    final fields = matching.extractedFields;
    final profile = ref.read(userProfileProvider);
    final fallback = profile.area.isNotEmpty
        ? '${profile.area}, ${profile.city}'
        : '';

    if (fields != null && fields.isNotEmpty) {
      final tiles = IntentDisplayModel.tilesFromExtractedFields(
        fields,
        fallbackLocation: fallback,
      );
      if (tiles.isNotEmpty) return tiles;
    }

    // Structural fallback when backend hasn't responded yet or returned nothing.
    return [
      if (fallback.isNotEmpty)
        IntentTileData(
          title: fallback,
          icon: Icons.location_on,
          bgColor: const Color(0xFFF0F9F4),
        ),
      const IntentTileData(
        title: 'Analyzing…',
        icon: Icons.hourglass_empty,
        bgColor: Color(0xFFF3F4F6),
      ),
    ];
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
    ref.read(chatFlowPhaseProvider.notifier).state = ChatFlowPhase.processing;
    _startProgressBar();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _wsSub?.cancel();
    _wsClient?.disconnect();
    super.dispose();
  }

  // ── Progress bar ──────────────────────────────────────────────────────────

  void _startProgressBar() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (_progress < 95 && mounted) setState(() => _progress += 0.8);
    });
  }

  // ── WebSocket connection ───────────────────────────────────────────────────

  void _connectWebSocket() {
    try {
      _wsClient = WebSocketClient();
      final stream = apiService.connectAgentStream(_wsClient!);

      // Give the socket time to open, then send the query.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        final query = ref.read(chatMessageProvider);
        _wsClient?.send({
          'query': query.isNotEmpty ? query : 'AC repair kar do',
          'lat': 33.649,
          'lng': 72.973,
          'session_id': _sessionId,
        });
      });

      _wsSub = stream.listen(
        (event) {
          if (!mounted) return;
          final type =
              (event['type'] ?? event['event'] ?? '').toString().toLowerCase();

          // Update dynamic stage detail from any trace content.
          final content = event['content']?.toString() ?? '';
          if (content.isNotEmpty) {
            setState(() => _lastTraceDetail = content.length > 64
                ? '${content.substring(0, 64)}…'
                : content);
          }

          switch (type) {
            case 'thinking':
            case 'orchestration_started':
              if (_stage < 1) setState(() => _stage = 0);
            case 'tool_call':
              if (_stage < 2) setState(() => _stage = 1);
            case 'tool_result':
            case 'step_completed':
              if (_stage < 3) setState(() => _stage = 2);
            case 'decision':
              if (_stage < 4) setState(() => _stage = 3);
            case 'completed':
            case 'orchestration_completed':
              _progressTimer?.cancel();
              final action =
                  (event['action'] as String? ?? '').toLowerCase().trim();
              if (action == 'ask_clarification') {
                ref
                    .read(matchingNotifierProvider.notifier)
                    .storeCoordinatorResult(event);
                ref.read(matchingNotifierProvider.notifier).clearForClarification();
                ref.read(chatFlowPhaseProvider.notifier).state =
                    ChatFlowPhase.processing;
                setState(() {
                  _stage = 3;
                  _progress = 100;
                });
                if (mounted) context.push(AppRoutes.lowConfidence);
                break;
              }
              setState(() {
                _stage = 4;
                _progress = 100;
              });
              ref
                  .read(matchingNotifierProvider.notifier)
                  .storeCoordinatorResult(event);
              _routeOnAction(event);
            case 'error':
              if (mounted) _handleWsError();
          }
        },
        onError: (_) {
          if (mounted) _handleWsError();
        },
        onDone: () {
          // Closed before a completed event — treat as failure.
          if (mounted && _stage < 4) _handleWsError();
        },
      );
    } catch (_) {
      _handleWsError();
    }
  }

  // ── Action-based routing ───────────────────────────────────────────────────

  /// Switches on the `action` field from the `completed` WS payload
  /// (or from the HTTP coordinator response) and navigates accordingly.
  ///
  /// | action              | navigation target                     |
  /// |---------------------|---------------------------------------|
  /// | ask_clarification   | AppRoutes.lowConfidence (push)        |
  /// | show_providers + [] | AppRoutes.noProviders (push)          |
  /// | show_providers + 1+ | IntentSummary → providerRanking (go) |
  /// | (unknown / null)    | IntentSummary if providers > 0        |
  void _routeOnAction(Map<String, dynamic> event) {
    final action =
        (event['action'] as String? ?? '').toLowerCase().trim();
    final providers = (event['providers'] ??
        event['matching_providers'] ??
        []) as List<dynamic>;

    switch (action) {
      case 'ask_clarification':
        // Usually handled in the WS/HTTP completed handler; guard for older payloads.
        if (ref.read(matchingNotifierProvider).coordinatorResult == null) {
          ref.read(matchingNotifierProvider.notifier).storeCoordinatorResult(event);
        }
        ref.read(matchingNotifierProvider.notifier).clearForClarification();
        ref.read(chatFlowPhaseProvider.notifier).state =
            ChatFlowPhase.processing;
        if (mounted) context.push(AppRoutes.lowConfidence);
        return;

      case 'show_providers':
        if (providers.isEmpty) {
          if (mounted) context.push(AppRoutes.noProviders);
        } else {
          _showIntentSummary();
        }
        return;

      default:
        if (providers.isNotEmpty) {
          _showIntentSummary();
        } else if (mounted) {
          context.push(AppRoutes.noProviders);
        }
    }
  }

  /// Transitions the chat phase to [ChatFlowPhase.intentSummary].
  void _showIntentSummary() {
    ref.read(chatFlowPhaseProvider.notifier).state =
        ChatFlowPhase.intentSummary;
    if (mounted) setState(() {});
  }

  // ── Error / fallback handling ──────────────────────────────────────────────

  /// Called on WS error / close before completion.
  ///
  /// Decision tree:
  /// • Backend **online** → automatically trigger HTTP coordinate (no user tap).
  ///   - HTTP success → cancel timer, advance to stage 4, route on action.
  ///   - HTTP failure → show error message in pipeline panel; NO timer fallback.
  /// • Backend **offline** → show "Demo offline pipeline" notice, then run the
  ///   timer-driven demo UI so the app stays usable without a network.
  void _handleWsError() {
    final backendOnline = ref.read(backendOnlineProvider);
    if (backendOnline) {
      // Automatically fall back to HTTP — no silent fake timer.
      _retryViaHttp();
    } else {
      _fallbackToTimer();
    }
  }

  /// HTTP fallback — calls /api/v1/agent/coordinate directly.
  ///
  /// Invoked automatically (not by a user button tap) when WS fails and the
  /// backend was reachable at startup.
  Future<void> _retryViaHttp() async {
    if (!mounted) return;
    // Reset progress so the bar animates through the HTTP call duration.
    setState(() {
      _stage = 0;
      _progress = 0;
      _lastTraceDetail = 'Switching to direct call…';
      _httpErrorMessage = null;
    });
    ref.read(chatFlowPhaseProvider.notifier).state = ChatFlowPhase.processing;
    _startProgressBar();

    final query = ref.read(chatMessageProvider);
    await ref.read(matchingNotifierProvider.notifier).coordinate(
          query: query.isNotEmpty ? query : 'AC repair kar do',
          lat: 33.649,
          lng: 72.973,
          sessionId: _sessionId,
        );

    if (!mounted) return;

    final ms = ref.read(matchingNotifierProvider);
    if (ms.error != null) {
      // HTTP also failed — do NOT fall through to the fake timer.
      // Show a real error in the pipeline panel instead.
      _progressTimer?.cancel();
      setState(() {
        _httpErrorMessage =
            'Could not reach backend. Check connection and retry.';
        _progress = 0;
      });
    } else {
      _progressTimer?.cancel();
      final result = ms.coordinatorResult ?? {};
      final action =
          (result['action'] as String? ?? ms.action ?? '').toLowerCase().trim();
      if (action == 'ask_clarification') {
        if (ms.coordinatorResult != null) {
          ref.read(matchingNotifierProvider.notifier).clearForClarification();
        }
        ref.read(chatFlowPhaseProvider.notifier).state =
            ChatFlowPhase.processing;
        setState(() {
          _stage = 3;
          _progress = 100;
          _lastTraceDetail = '';
        });
        if (mounted) context.push(AppRoutes.lowConfidence);
        return;
      }
      setState(() {
        _stage = 4;
        _progress = 100;
        _lastTraceDetail = '';
      });
      _routeOnAction(result);
    }
  }

  /// Timer-driven demo pipeline — ONLY used when [backendOnlineProvider] is
  /// false (i.e. backend was unreachable at startup).
  ///
  /// Never called when the backend is online, even if both WS and HTTP failed.
  void _fallbackToTimer() {
    if (!mounted) return;
    // Show a single-shot notice that we are in demo mode.
    setState(() => _lastTraceDetail = 'Demo offline pipeline');
    Timer.periodic(AppDurations.agentStep, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_stage < _stages.length - 1) {
        setState(() => _stage++);
      } else if (_stage == _stages.length - 1) {
        t.cancel();
        _showIntentSummary();
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final message = ref.watch(chatMessageProvider);
    final phase = ref.watch(chatFlowPhaseProvider);
    final profile = ref.watch(userProfileProvider);
    final matching = ref.watch(matchingNotifierProvider);
    final confidence = matching.confidence;

    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HTTP error banner (backend online, both WS + HTTP failed) ─
              if (_httpErrorMessage != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _httpErrorMessage!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _httpErrorMessage = null;
                            _stage = 0;
                            _progress = 0;
                            _lastTraceDetail = '';
                          });
                          _wsSub?.cancel();
                          _wsClient?.disconnect();
                          _startProgressBar();
                          _connectWebSocket();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              // ── Greeting ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  'Salam, ${profile.name.split(' ').first} 👋',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              // ── Chat area ─────────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // User message bubble
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppColors.userBubbleGradient,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              message,
                              style:
                                  const TextStyle(fontSize: 15, height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '10:32 AM',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // AI response area
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AiOrbLogo(size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Processing phase — pipeline panel
                              if (phase == ChatFlowPhase.processing)
                                AiPipelinePanel(
                                  stages: _stages,
                                  currentIndex: _stage,
                                  progress: _progress / 100,
                                ),

                              // Intent summary phase — dynamic tiles + confidence
                              if (phase == ChatFlowPhase.intentSummary ||
                                  phase == ChatFlowPhase.complete) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _editingIntent
                                        ? 'Edit karein aur confirm karein:'
                                        : 'Mujhe samajh aaya — aap ko chahiye:',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                IntentSummaryCard(
                                  // Dynamic tiles — built from backend
                                  // extracted_fields, never hardcoded.
                                  tiles: _buildTiles(),
                                  // Real confidence from coordinator response.
                                  confidence: confidence,
                                  showEditActions: _editingIntent,
                                  onConfirm: () =>
                                      context.go(AppRoutes.providerRanking),
                                  onEdit: () =>
                                      setState(() => _editingIntent = true),
                                  onRerun: () {
                                    setState(() {
                                      _editingIntent = false;
                                      _stage = 0;
                                      _progress = 0;
                                      _lastTraceDetail = '';
                                      _httpErrorMessage = null;
                                    });
                                    ref
                                        .read(chatFlowPhaseProvider.notifier)
                                        .state = ChatFlowPhase.processing;
                                    _wsSub?.cancel();
                                    _wsClient?.disconnect();
                                    _startProgressBar();
                                    _connectWebSocket();
                                  },
                                  onCancel: () =>
                                      setState(() => _editingIntent = false),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _ChatInputBar(onInterrupt: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom input bar ──────────────────────────────────────────────────────────

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({required this.onInterrupt});
  final VoidCallback onInterrupt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
              color: AppColors.glassShadow,
              blurRadius: 16,
              offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.bgSecondary,
            child: IconButton(
              icon: const Icon(Icons.mic, size: 20),
              onPressed: onInterrupt,
            ),
          ),
          const Expanded(
            child: Text(
              'Type to interrupt or wait...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accentLavender,
            child:
                IconButton(icon: const Icon(Icons.send, size: 18), onPressed: null),
          ),
        ],
      ),
    );
  }
}
