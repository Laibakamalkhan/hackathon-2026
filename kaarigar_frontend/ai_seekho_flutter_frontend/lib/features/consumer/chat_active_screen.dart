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

  // Real-time WebSocket (replaces the fake agentTimer)
  Timer? _progressTimer;
  WebSocketClient? _wsClient;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  // Visual stages — unchanged from original
  static final _stages = [
    AgentStage(label: 'Understanding request', detail: 'AC Repair · Urgency: HIGH · G-13', color: AppColors.accentLavender, icon: Icons.psychology_outlined),
    AgentStage(label: 'Searching providers',   detail: 'Scanning 47 technicians in area',  color: AppColors.accentSand,     icon: Icons.search),
    AgentStage(label: 'Ranking options',        detail: 'Evaluating 8 factors for best match', color: AppColors.warning,   icon: Icons.trending_up),
    AgentStage(label: 'Checking availability',  detail: '3 providers available tomorrow AM',   color: AppColors.success,   icon: Icons.event_available_outlined),
    AgentStage(label: 'Analysis complete',      detail: '3 best matches found!',               color: AppColors.success,   icon: Icons.check_circle_outline),
  ];

  List<IntentTileData> get _tiles => [
        IntentTileData(title: 'AC Repair', subtitle: 'High Urgency', icon: Icons.build_outlined, bgColor: const Color(0xFFFDF2F2)),
        IntentTileData(title: '${ref.read(userProfileProvider).area}, ${ref.read(userProfileProvider).city}', icon: Icons.location_on, bgColor: const Color(0xFFF0F9F4)),
        IntentTileData(title: 'Kal Subah', icon: Icons.schedule, bgColor: const Color(0xFFF3F4F6)),
        IntentTileData(title: 'Budget Sensitive', icon: Icons.savings_outlined, bgColor: const Color(0xFFFEF9F2)),
      ];

  @override
  void initState() {
    super.initState();
    ref.read(chatFlowPhaseProvider.notifier).state = ChatFlowPhase.processing;
    _startProgressBar();
    _connectWebSocket();
  }

  void _startProgressBar() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (_progress < 95 && mounted) setState(() => _progress += 0.8);
    });
  }

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
          'session_id': 'session-${DateTime.now().millisecondsSinceEpoch}',
        });
      });

      _wsSub = stream.listen(
        (event) {
          if (!mounted) return;
          final type = (event['type'] ?? event['event'] ?? '').toString().toLowerCase();
          switch (type) {
            case 'thinking':
            case 'orchestration_started':
              if (_stage < 1) setState(() => _stage = 0);
            case 'tool_call':
              if (_stage < 2) setState(() => _stage = 1);
            case 'tool_result':
            case 'step_completed':
              if (_stage < 3) setState(() => _stage = 2);
            case 'completed':
            case 'orchestration_completed':
              _progressTimer?.cancel();
              setState(() { _stage = 4; _progress = 100; });
              // Store result so ProviderRankingScreen / PriceBreakdownScreen can use it.
              ref.read(matchingNotifierProvider.notifier).storeCoordinatorResult(event);
              _onPipelineComplete();
            case 'error':
              if (mounted) _fallbackToTimer();
          }
        },
        onError: (_) { if (mounted) _fallbackToTimer(); },
        onDone: ()  { if (mounted && _stage < 4) _fallbackToTimer(); },
      );
    } catch (_) {
      _fallbackToTimer();
    }
  }

  /// Original fake-timer behaviour used when the backend is unreachable.
  void _fallbackToTimer() {
    Timer.periodic(AppDurations.agentStep, (t) {
      if (!mounted) { t.cancel(); return; }
      if (_stage < _stages.length - 1) {
        setState(() => _stage++);
      } else if (_stage == _stages.length - 1) {
        t.cancel();
        _onPipelineComplete();
      }
    });
  }

  void _onPipelineComplete() {
    ref.read(chatFlowPhaseProvider.notifier).state =
        ref.read(chatNeedsUrgencyProvider) ? ChatFlowPhase.followUp : ChatFlowPhase.intentSummary;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _wsSub?.cancel();
    _wsClient?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = ref.watch(chatMessageProvider);
    final phase   = ref.watch(chatFlowPhaseProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text('Salam, ${profile.name.split(' ').first} 👋',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppColors.userBubbleGradient,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20), topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Text(message, style: const TextStyle(fontSize: 15, height: 1.4)),
                          ),
                          const SizedBox(height: 4),
                          Text('10:32 AM', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AiOrbLogo(size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (phase == ChatFlowPhase.processing)
                                AiPipelinePanel(stages: _stages, currentIndex: _stage, progress: _progress / 100),
                              if (phase == ChatFlowPhase.intentSummary || phase == ChatFlowPhase.complete) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                  child: Text(
                                    _editingIntent ? 'Edit karein aur confirm karein:' : 'Mujhe samajh aaya — aap ko chahiye:',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                IntentSummaryCard(
                                  tiles: _tiles,
                                  showEditActions: _editingIntent,
                                  onConfirm: () => context.go(AppRoutes.providerRanking),
                                  onEdit: () => setState(() => _editingIntent = true),
                                  onRerun: () {
                                    setState(() { _editingIntent = false; _stage = 0; _progress = 0; });
                                    ref.read(chatFlowPhaseProvider.notifier).state = ChatFlowPhase.processing;
                                    _wsSub?.cancel();
                                    _wsClient?.disconnect();
                                    _connectWebSocket();
                                  },
                                  onCancel: () => setState(() => _editingIntent = false),
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
        boxShadow: const [BoxShadow(color: AppColors.glassShadow, blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: AppColors.bgSecondary,
              child: IconButton(icon: const Icon(Icons.mic, size: 20), onPressed: onInterrupt)),
          const Expanded(
            child: Text('Type to interrupt or wait...',
                style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 14)),
          ),
          CircleAvatar(radius: 20, backgroundColor: AppColors.accentLavender,
              child: IconButton(icon: const Icon(Icons.send, size: 18), onPressed: null)),
        ],
      ),
    );
  }
}
