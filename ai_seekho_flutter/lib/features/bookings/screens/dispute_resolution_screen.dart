import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';
import 'package:ai_seekho_flutter/shared/widgets/agent_trace_panel.dart';

class DisputeResolutionScreen extends StatefulWidget {
  final Map<String, dynamic>? resolutionData;
  final String bookingId;
  final String category;
  final String details;

  const DisputeResolutionScreen({
    super.key,
    this.resolutionData,
    this.bookingId = '',
    this.category = '',
    this.details = '',
  });

  @override
  State<DisputeResolutionScreen> createState() => _DisputeResolutionScreenState();
}

class _DisputeResolutionScreenState extends State<DisputeResolutionScreen> {
  late List<TraceStep> _steps;
  int _currentStepIndex = 0;
  Timer? _timer;
  bool _isFinished = false;
  late bool _escalationNeeded;
  late String? _escalationReason;
  late String _userMessageUrdu;
  late String _userMessageEn;
  late String _providerAction;
  late Map<String, dynamic> _resolution;
  late String _category;

  static const List<TraceStep> _defaultSteps = [
    TraceStep(title: "Reviewing Evidence", titleUrdu: "شواہد کا جائزہ",
        description: "Analyzing booking & user description...", descriptionUrdu: "", status: 'running'),
    TraceStep(title: "Applying Refund Rules", titleUrdu: "معاوضے کے اصول",
        description: "Matching dispute type to rule table...", descriptionUrdu: "", status: 'pending'),
    TraceStep(title: "Generating AI Resolution", titleUrdu: "اے آئی فیصلہ",
        description: "Gemini final verdict...", descriptionUrdu: "", status: 'pending'),
    TraceStep(title: "Updating Provider Record", titleUrdu: "فراہم کنندہ ریکارڈ",
        description: "Logging offense and penalty...", descriptionUrdu: "", status: 'pending'),
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.resolutionData ?? {};
    _escalationNeeded = d['escalation_needed'] == true;
    _escalationReason = d['escalation_reason'] as String?;
    _userMessageUrdu = d['user_message_urdu'] as String? ?? '';
    _userMessageEn = d['user_message_en'] as String? ?? '';
    _providerAction = d['provider_action'] as String? ?? 'none';
    _resolution = d['resolution'] as Map<String, dynamic>? ?? {};
    _category = d['category'] as String? ?? widget.category;
    _steps = List.from(_defaultSteps);
    _startOrchestration();
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startOrchestration() {
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (!mounted) return;
      setState(() {
        _steps[_currentStepIndex] = TraceStep(
          title: _steps[_currentStepIndex].title,
          titleUrdu: _steps[_currentStepIndex].titleUrdu,
          description: _steps[_currentStepIndex].description,
          descriptionUrdu: _steps[_currentStepIndex].descriptionUrdu,
          status: 'completed',
        );
        _currentStepIndex++;
        if (_currentStepIndex < _steps.length) {
          _steps[_currentStepIndex] = TraceStep(
            title: _steps[_currentStepIndex].title,
            titleUrdu: _steps[_currentStepIndex].titleUrdu,
            description: _steps[_currentStepIndex].description,
            descriptionUrdu: _steps[_currentStepIndex].descriptionUrdu,
            status: 'running',
          );
        } else { _timer?.cancel(); _isFinished = true; }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final amountPkr = _resolution['amount_pkr'] as int? ?? 0;
    final resolutionType = (_resolution['type'] as String? ?? 'no_action').replaceAll('_', ' ').toUpperCase();

    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.topLeft,
                  child: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => context.pop())),
                const SizedBox(height: 10),
                const Text("AI Dispute Arbitration", style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Text("اے آئی ثالثی کا عمل", style: AppTextStyles.urdu.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      AgentTracePanel(steps: _steps),
                      const SizedBox(height: 20),
                      if (_isFinished) ...[
                        if (_escalationNeeded)
                          GlassCard(
                            color: AppColors.error.withOpacity(0.15),
                            borderColor: AppColors.error,
                            padding: const EdgeInsets.all(16),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Row(children: [
                                Icon(Icons.escalator_warning, color: AppColors.error, size: 22),
                                SizedBox(width: 8),
                                Text("ESCALATED — Human Review", style: AppTextStyles.bodyBold),
                              ]),
                              const SizedBox(height: 10),
                              Text(_userMessageUrdu.isNotEmpty ? _userMessageUrdu
                                  : "Aap ka case hamari team ko bheja ja raha hai. 24 ghante mein rabta kiya jayega.",
                                  style: AppTextStyles.caption),
                            ]),
                          )
                        else
                          GlassCard(
                            color: AppColors.success.withOpacity(0.15),
                            borderColor: AppColors.success,
                            padding: const EdgeInsets.all(18),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              Row(children: [
                                const Icon(Icons.gavel, color: Colors.green, size: 24),
                                const SizedBox(width: 10),
                                Text("AI VERDICT / فیصلہ",
                                    style: AppTextStyles.bodyBold.copyWith(color: Colors.green)),
                              ]),
                              const SizedBox(height: 12),
                              Text(_userMessageUrdu.isNotEmpty ? _userMessageUrdu
                                  : "Aap ki shikayat review ho gayi.", style: AppTextStyles.caption),
                              if (_userMessageEn.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(_userMessageEn,
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                              ],
                              if (amountPkr > 0) ...[
                                const SizedBox(height: 14),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(resolutionType,
                                        style: AppTextStyles.caption.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text("PKR $amountPkr",
                                        style: AppTextStyles.bodyBold.copyWith(fontSize: 20, color: Colors.green[800])),
                                  ]),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                                        foregroundColor: Colors.green[800], elevation: 0),
                                    icon: const Icon(Icons.copy, size: 14),
                                    label: const Text("Copy"),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: "PKR $amountPkr refund - $_category"));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Copied!")));
                                    },
                                  ),
                                ]),
                              ],
                              if (_providerAction != 'none' && _providerAction != 'rating_updated') ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                                  ),
                                  child: Text("Provider: ${_providerAction.replaceAll('_', ' ').toUpperCase()}",
                                      style: AppTextStyles.caption.copyWith(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ]),
                          ),
                      ],
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: _isFinished ? "Back to Home / ہوم پیج" : "Arbitrating Dispute...",
                  onPressed: _isFinished ? () => context.go('/home') : null,
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
