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

  const IntentConfirmScreen({
    super.key,
    required this.query,
  });

  @override
  State<IntentConfirmScreen> createState() => _IntentConfirmScreenState();
}

class _IntentConfirmScreenState extends State<IntentConfirmScreen> {
  double _confidence = 0.92;
  
  bool _isLoading = true;
  List<String> _terminalLogs = ["> SYSTEM: Establishing secure link to Google ADK..."];
  List<Map<String, String>> _tags = [];
  List<dynamic> _matchingProviders = [];

  String get _extractedService {
    if (_tags.isEmpty) return "general";
    final serviceTag = _tags.firstWhere(
      (tag) => tag["category"] == "service", 
      orElse: () => {"val": "general"}
    );
    return serviceTag["val"] ?? "general";
  }

  @override
  void initState() {
    super.initState();
    _startMatchmaking();
  }

  Future<void> _startMatchmaking() async {
    final sessionId = 'sess-${DateTime.now().millisecondsSinceEpoch}';
    
    // 1. Connect WebSocket for Real-time Traces
    try {
      final wsStream = apiService.connectTraceWebSocket(sessionId);
      wsStream.listen((event) {
        if (event['event'] == 'orchestration_started') {
          _addLog("> SYSTEM: ${event['message']}");
        } else if (event['event'] == 'step_completed') {
          _addLog("> AGENT THOUGHT: ${event['step']}");
        } else if (event['event'] == 'orchestration_completed') {
          _addLog("> SYSTEM: Matchmaking complete. Returning providers...");
        } else if (event['event'] == 'error') {
          _addLog("> [ERROR]: ${event['message']}");
        }
      }, onError: (e) {
        _addLog("> [WS ERROR]: $e");
      });
    } catch (e) {
      _addLog("> [WARNING]: Could not connect to telemetry socket.");
    }

    // 2. HTTP POST Match to Trigger Orchestrator
    try {
      final req = MatchRequest(
        query: widget.query,
        lat: 33.649, // Mock Location
        lng: 72.973,
        sessionId: sessionId,
      );
      
      final response = await apiService.matchProviders(req);
      
      // Parse Response gracefully
      if (response.containsKey('intent_parsed')) {
        final rawTags = response['intent_parsed'] as Map<String, dynamic>?;
        _tags = _convertToUITags(rawTags ?? {});
      } else {
        _tags = _parseQueryFallback(widget.query); // Fallback
      }
      
      if (response.containsKey('matching_providers')) {
        _matchingProviders = response['matching_providers'] as List<dynamic>;
      }
      
    } catch (e) {
      _addLog("> [FATAL ERROR]: Connection to AI Engine Failed.");
      _addLog("> SYSTEM: $e");
      _addLog("> SYSTEM: Falling back to local offline mock engine...");
      await Future.delayed(const Duration(seconds: 1));
      _tags = _parseQueryFallback(widget.query); 
    }
    
    // Slight delay so user can read the final log before transition
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addLog(String text) {
    if (mounted) {
      setState(() {
        _terminalLogs.add(text);
      });
    }
  }

  List<Map<String, String>> _convertToUITags(Map<String, dynamic> raw) {
    List<Map<String, String>> uiTags = [];
    raw.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        uiTags.add({
          "label": "$key: $value",
          "val": value.toString(),
          "category": key,
        });
      }
    });
    return uiTags;
  }

  // Old hardcoded logic moved to fallback
  List<Map<String, String>> _parseQueryFallback(String query) {
    final q = query.toLowerCase();
    List<Map<String, String>> parsedTags = [];
    if (q.contains("ac") || q.contains("cooler") || q.contains("fridge")) {
      parsedTags.add({"label": "Service: AC & Cooling", "val": "ac_repair", "category": "service"});
    } else if (q.contains("bijli") || q.contains("wire") || q.contains("light") || q.contains("button")) {
      parsedTags.add({"label": "Service: Electrical", "val": "electric", "category": "service"});
    } else if (q.contains("pani") || q.contains("pipe") || q.contains("plumber") || q.contains("motor")) {
      parsedTags.add({"label": "Service: Plumbing", "val": "plumbing", "category": "service"});
    } else {
      parsedTags.add({"label": "Service: General Repair", "val": "general", "category": "service"});
    }
    if (q.contains("gas") && q.contains("leak")) {
      parsedTags.add({"label": "Fault: Gas Leak", "val": "gas_leak", "category": "fault"});
    } else {
      parsedTags.add({"label": "Fault: Diagnostic Needed", "val": "diagnostic", "category": "fault"});
    }
    return parsedTags;
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
        final textController = TextEditingController();
        return AlertDialog(
          title: const Text("Add Custom Filter Tag"),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "E.g. Brand: Dawlance"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  setState(() {
                    _tags.add({
                      "label": textController.text.trim(),
                      "val": textController.text.toLowerCase().replaceAll(' ', '_'),
                      "category": "custom"
                    });
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
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _terminalLogs[index],
                      style: TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
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
          "Our multi-agent system parsed the following parameters from your query. Tap 'x' to remove any incorrect item or tweak filters.",
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
                    Text("EXTRACTED FILTERS / فلٹرز", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    IconButton(icon: const Icon(Icons.add_circle, color: AppColors.textPrimary, size: 24), onPressed: _addCustomTag),
                  ],
                ),
                const SizedBox(height: 12),
                if (_tags.isEmpty)
                  const Expanded(child: Center(child: Text("No tags remaining.", style: AppTextStyles.caption)))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_tags.length, (index) {
                      final tag = _tags[index];
                      return Chip(
                        backgroundColor: AppColors.lavender.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.chip), side: BorderSide(color: AppColors.lavender.withOpacity(0.6))),
                        label: Text(tag["label"]!, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
            context.push('/provider-ranking?service=${Uri.encodeComponent(_extractedService)}', extra: _matchingProviders);
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
