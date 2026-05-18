import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';
import 'package:ai_seekho_flutter/shared/widgets/agent_trace_panel.dart';

class ChatActiveScreen extends StatefulWidget {
  final String query;

  const ChatActiveScreen({
    super.key,
    required this.query,
  });

  @override
  State<ChatActiveScreen> createState() => _ChatActiveScreenState();
}

class _ChatActiveScreenState extends State<ChatActiveScreen> {
  final List<TraceStep> _steps = [
    const TraceStep(
      title: "Analyzing Intent",
      titleUrdu: "ارادے کا تجزیہ",
      description: "Parsing service requirement details...",
      descriptionUrdu: "سروس کی ضرورت کی تفصیلات کا تجزیہ ہو رہا ہے...",
      status: 'running',
    ),
    const TraceStep(
      title: "Locating Nearby Specialists",
      titleUrdu: "قریبی ماہرین تلاش کرنا",
      description: "Querying geo-databases in sector G-13...",
      descriptionUrdu: "سیکٹر جی-13 میں قریبی ماہرین تلاش ہو رہے ہیں...",
      status: 'pending',
    ),
    const TraceStep(
      title: "Bidding & Price Negotiation",
      titleUrdu: "قیمت کا تعین",
      description: "Evaluating primary service base rates...",
      descriptionUrdu: "سروس کے بنیادی نرخوں کا جائزہ لیا جا رہا ہے...",
      status: 'pending',
    ),
    const TraceStep(
      title: "AI Trust & Match Validation",
      titleUrdu: "اے آئی میچ تصدیق",
      description: "Verifying provider credentials & history...",
      descriptionUrdu: "سروس فراہم کنندہ کی تصدیق ہو رہی ہے...",
      status: 'pending',
    ),
  ];

  int _currentStepIndex = 0;
  Timer? _timer;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startOrchestration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startOrchestration() {
    _timer = Timer.periodic(const Duration(milliseconds: 2200), (timer) {
      if (!mounted) return;

      setState(() {
        // Complete the active step
        _steps[_currentStepIndex] = TraceStep(
          title: _steps[_currentStepIndex].title,
          titleUrdu: _steps[_currentStepIndex].titleUrdu,
          description: _steps[_currentStepIndex].description,
          descriptionUrdu: _steps[_currentStepIndex].descriptionUrdu,
          status: 'completed',
        );

        _currentStepIndex++;

        if (_currentStepIndex < _steps.length) {
          // Set next step as running
          _steps[_currentStepIndex] = TraceStep(
            title: _steps[_currentStepIndex].title,
            titleUrdu: _steps[_currentStepIndex].titleUrdu,
            description: _steps[_currentStepIndex].description,
            descriptionUrdu: _steps[_currentStepIndex].descriptionUrdu,
            status: 'running',
          );
        } else {
          _timer?.cancel();
          _isFinished = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
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
                const Text(
                  "AI Matchmaking Pipeline",
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  "اے آئی میچ میکنگ پائپ لائن",
                  style: AppTextStyles.urdu.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    "\"${widget.query}\"",
                    style: AppTextStyles.bodyBold.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: AgentTracePanel(steps: _steps),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: _isFinished ? "View Match Results / نتائج دیکھیں" : "Orchestrating... / جاری ہے...",
                  onPressed: _isFinished
                      ? () {
                          // Route directly to intent confirmation
                          context.push(
                            '/intent-confirm?query=${Uri.encodeComponent(widget.query)}',
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
