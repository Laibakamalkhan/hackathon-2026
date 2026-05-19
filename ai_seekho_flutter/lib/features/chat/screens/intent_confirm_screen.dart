import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';
import 'package:ai_seekho_flutter/shared/widgets/confidence_badge.dart';
import 'package:ai_seekho_flutter/core/network/api_service.dart';
import 'package:ai_seekho_flutter/core/network/models.dart';

class IntentConfirmScreen extends StatefulWidget {
  final String query;

  const IntentConfirmScreen({super.key, required this.query});

  @override
  State<IntentConfirmScreen> createState() => _IntentConfirmScreenState();
}

class _IntentConfirmScreenState extends State<IntentConfirmScreen> {
  double _confidence = 0.0;
  bool _isLoading = true;
  List<String> _terminalLogs = ["> SYSTEM: Establishing secure link to AI Seekho Agents..."];
  List<Map<String, String>> _tags = [];
  List<dynamic> _matchingProviders = [];
  Map<String, dynamic>? _quote;
  Map<String, dynamic>? _handoff;

  // Multi-turn state
  List<Map<String, dynamic>> _conversationHistory = [];
  String? _pendingFollowUp;

  final String _sessionId = 'sess-${DateTime.now().millisecondsSinceEpoch}';

  String get _extractedService {
    if (_tags.isEmpty) return "general";
    final t = _tags.firstWhere(
      (t) => t["category"] == "service_type" || t["category"] == "service",
      orElse: () => {"val": "general"},
    );
    return t["val"] ?? "general";
  }

  @override
  void initState() {
    super.initState();
    _runCoordinator(widget.query);
  }

  void _addLog(String text) {
    if (mounted) setState(() => _terminalLogs.add(text));
  }

  Future<void> _runCoordinator(String userMessage) async {
    setState(() { _isLoading = true; });
    _addLog("> AGENT: Processing: \"${userMessage.substring(0, userMessage.length.clamp(0, 60))}...\"");

    // Build conversation history with the new message
    final messages = List<Map<String, dynamic>>.from(_conversationHistory)
      ..add({"role": "user", "content": userMessage});

    try {
      // Connect old WebSocket for demo trace logs
      try {
        final wsStream = apiService.connectTraceWebSocket(_sessionId);
        wsStream.listen((event) {
          if (event['event'] == 'orchestration_started') {
            _addLog("> SYSTEM: ${event['message']}");
          } else if (event['event'] == 'step_completed') {
            _addLog("> AGENT THOUGHT: ${event['step']?['reasoning'] ?? ''}");
          } else if (event['event'] == 'orchestration_completed') {
            _addLog("> SYSTEM: Matchmaking complete. Returning providers...");
          }
        }, onError: (_) => _addLog("> [WARNING]: Telemetry socket unavailable."));
      } catch (_) {
        _addLog("> [WARNING]: Could not connect to telemetry socket.");
      }

      // POST to new /api/v1/agent/coordinate
      final result = await apiService.agentCoordinate(
        query: userMessage,
        lat: 33.649,
        lng: 72.973,
        sessionId: _sessionId,
        conversationHistory: _conversationHistory.isNotEmpty ? _conversationHistory : null,
      );

      // Log agent trace events
      final traceEvents = result['trace_events'] as List? ?? [];
      for (final evt in traceEvents.take(6)) {
        final e = evt as Map<String, dynamic>;
        _addLog("> ${(e['type'] ?? 'AGENT').toString().toUpperCase()}: ${(e['content'] as String? ?? '').substring(0, (e['content'] as String? ?? '').length.clamp(0, 100))}");
      }

      final action = result['action'] as String? ?? 'show_providers';
      final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.70;

      // Update conversation history
      _conversationHistory = List<Map<String, dynamic>>.from(messages)
        ..add({"role": "model", "content": result['message'] ?? ''});

      if (action == 'ask_clarification') {
        // Multi-turn: show follow-up question, keep loading false but remain on terminal UI
        final followUp = result['message'] as String? ?? "Thodi aur tafseelaat dein please.";
        _addLog("> AGENT: $followUp");
        setState(() {
          _pendingFollowUp = followUp;
          _confidence = confidence;
          _isLoading = false;
        });
        return;
      }

      // Parse providers
      final providers = result['providers'] as List? ?? [];
      _matchingProviders = providers;

      // Build UI tags from matching providers or intent
      if (result.containsKey('providers') && providers.isNotEmpty) {
        final top = providers[0] as Map<String, dynamic>;
        _tags = [
          {"label": "Service: ${_formatService(result)}", "val": _extractServiceFromResult(result), "category": "service_type"},
          {"label": "Provider: ${top['name'] ?? 'Matched'}", "val": top['pid'] ?? '', "category": "provider"},
          {"label": "Rating: ${(top['rating'] ?? 4.0).toStringAsFixed(1)}★", "val": "${top['rating'] ?? 4.0}", "category": "rating"},
          if ((top['distance_km'] ?? 0) > 0)
            {"label": "Distance: ${(top['distance_km'] as num).toStringAsFixed(1)}km", "val": "${top['distance_km']}", "category": "distance"},
        ];
      }

      _quote = result['quote'] as Map<String, dynamic>?;
      _handoff = result['handoff'] as Map<String, dynamic>?;

      _addLog("> SYSTEM: Match complete. ${providers.length} providers found.");
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _confidence = confidence;
          _isLoading = false;
          _pendingFollowUp = null;
        });
      }

    } catch (e) {
      _addLog("> [FATAL ERROR]: Connection to AI Engine failed.");
      _addLog("> SYSTEM: ${e.toString().substring(0, e.toString().length.clamp(0, 120))}");
      _addLog("> SYSTEM: Falling back to local offline mode...");
      await Future.delayed(const Duration(seconds: 1));
      _tags = _parseQueryFallback(widget.query);
      if (mounted) {
        setState(() { _confidence = 0.70; _isLoading = false; });
      }
    }
  }

  String _formatService(Map<String, dynamic> result) {
    final providers = result['providers'] as List? ?? [];
    if (providers.isNotEmpty) {
      final top = providers[0] as Map<String, dynamic>;
      return (top['service_category'] as String? ?? 'General Repair')
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' ');
    }
    return 'General Repair';
  }

  String _extractServiceFromResult(Map<String, dynamic> result) {
    final providers = result['providers'] as List? ?? [];
    if (providers.isNotEmpty) {
      final top = providers[0] as Map<String, dynamic>;
      return top['service_category'] as String? ?? 'general';
    }
    return 'general';
  }

  List<Map<String, String>> _parseQueryFallback(String query) {
    final q = query.toLowerCase();
    List<Map<String, String>> tags = [];
    if (q.contains("ac") || q.contains("cooler") || q.contains("fridge")) {
      tags.add({"label": "Service: AC & Cooling", "val": "ac_repair", "category": "service_type"});
    } else if (q.contains("bijli") || q.contains("wire") || q.contains("light")) {
      tags.add({"label": "Service: Electrical", "val": "electric", "category": "service_type"});
    } else if (q.contains("pani") || q.contains("pipe") || q.contains("plumber")) {
      tags.add({"label": "Service: Plumbing", "val": "plumbing", "category": "service_type"});
    } else {
      tags.add({"label": "Service: General Repair", "val": "general", "category": "service_type"});
    }
    return tags;
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
      _confidence = (_confidence - 0.08).clamp(0.4, 1.0);
    });
  }

  void _addCustomTag() {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text("Add Custom Filter Tag"),
          content: TextField(controller: ctrl,
              decoration: const InputDecoration(hintText: "E.g. Brand: Dawlance")),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() {
                    _tags.add({"label": ctrl.text.trim(),
                        "val": ctrl.text.toLowerCase().replaceAll(' ', '_'),
                        "category": "custom"});
                    _confidence = (_confidence + 0.03).clamp(0.0, 1.0);
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: _isLoading ? _buildTerminalUI() : _buildConfirmationUI(),
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Xidmat Agents Orchestrator", style: AppTextStyles.heading1),
        const SizedBox(height: 20),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16.0),
            borderColor: Colors.greenAccent.withOpacity(0.5),
            child: Container(
              color: Colors.black.withOpacity(0.8),
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _terminalLogs.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(_terminalLogs[index],
                      style: const TextStyle(fontFamily: 'Courier',
                          color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: CircularProgressIndicator(color: AppColors.lavender)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConfirmationUI() {
    // If follow-up question pending, show clarification input
    if (_pendingFollowUp != null) {
      return _buildClarificationUI();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Confirm AI Intent Parsing", style: AppTextStyles.heading1),
        const SizedBox(height: 4),
        Text("اے آئی ارادے کی تصدیق", style: AppTextStyles.urdu.copyWith(fontSize: 16)),
        const SizedBox(height: 16),
        Center(child: ConfidenceBadge(score: _confidence)),
        const SizedBox(height: 24),
        Text(
          "Our multi-agent system parsed the following parameters. Tap 'x' to remove incorrect items or add custom filters.",
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("EXTRACTED FILTERS / فلٹرز",
                        style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    IconButton(
                        icon: const Icon(Icons.add_circle, color: AppColors.textPrimary, size: 24),
                        onPressed: _addCustomTag),
                  ],
                ),
                const SizedBox(height: 12),
                if (_tags.isEmpty)
                  const Expanded(
                      child: Center(child: Text("No tags remaining.", style: AppTextStyles.caption)))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_tags.length, (index) {
                      final tag = _tags[index];
                      return Chip(
                        backgroundColor: AppColors.lavender.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                            side: BorderSide(color: AppColors.lavender.withOpacity(0.6))),
                        label: Text(tag["label"]!,
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        onDeleted: () => _removeTag(index),
                        deleteIconColor: AppColors.textPrimary,
                        deleteIcon: const Icon(Icons.close, size: 14),
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: "Find Providers / تلاش کریں",
          onPressed: () {
            context.push(
              '/provider-ranking?service=${Uri.encodeComponent(_extractedService)}',
              extra: _matchingProviders,
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildClarificationUI() {
    final ctrl = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Agent Question / سوال", style: AppTextStyles.heading1),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderColor: AppColors.lavender.withOpacity(0.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.smart_toy, color: AppColors.lavender, size: 20),
                const SizedBox(width: 8),
                const Text("AI Agent", style: AppTextStyles.bodyBold),
              ]),
              const SizedBox(height: 12),
              Text(_pendingFollowUp ?? '', style: AppTextStyles.body.copyWith(height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Apna jawab yahan likhein...",
              border: InputBorder.none,
            ),
            style: AppTextStyles.body,
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) _runCoordinator(val.trim());
            },
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: "Reply / جواب دیں",
          onPressed: () {
            if (ctrl.text.trim().isNotEmpty) _runCoordinator(ctrl.text.trim());
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
