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
  final String bookingId;
  final String category;
  final String details;

  const DisputeResolutionScreen({
    super.key,
    required this.bookingId,
    required this.category,
    required this.details,
  });

  @override
  State<DisputeResolutionScreen> createState() => _DisputeResolutionScreenState();
}

class _DisputeResolutionScreenState extends State<DisputeResolutionScreen> {
  final List<TraceStep> _steps = [
    const TraceStep(
      title: "Reviewing Claim Evidence",
      titleUrdu: "شواہد کا جائزہ",
      description: "Analyzing user input details & attachments...",
      descriptionUrdu: "صارف کی فراہم کردہ تفصیلات کا جائزہ لیا جا رہا ہے...",
      status: 'running',
    ),
    const TraceStep(
      title: "Evaluating Booking Standards",
      titleUrdu: "معیارات کا جائزہ",
      description: "Matching standard rates against actual charged price...",
      descriptionUrdu: "سروس کے بنیادی نرخوں سے چارج شدہ رقم کا موازنہ...",
      status: 'pending',
    ),
    const TraceStep(
      title: "Resolving Financial Adjustment",
      titleUrdu: "رقم کا تصفیہ",
      description: "Calculating optimal compensatory refund credits...",
      descriptionUrdu: "صارف کے لیے مناسب معاوضے کا حساب لگانا...",
      status: 'pending',
    ),
    const TraceStep(
      title: "Issuing Redressal Voucher",
      titleUrdu: "واؤچر کا اجراء",
      description: "Finalizing agreement contract & promo generation...",
      descriptionUrdu: "حتمی تصفیہ اور پرومو کوڈ جنریشن مکمل...",
      status: 'pending',
    ),
  ];

  int _currentStepIndex = 0;
  Timer? _timer;
  bool _isFinished = false;
  final String _promoCode = "SEEKHOCARE500";

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
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
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
        } else {
          _timer?.cancel();
          _isFinished = true;
        }
      });
    });
  }

  void _copyPromoCode() {
    Clipboard.setData(ClipboardData(text: _promoCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Promo code copied to clipboard!")),
    );
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
                  "AI Dispute Arbitration",
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  "اے آئی ثالثی کا عمل",
                  style: AppTextStyles.urdu.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progressive trace steps
                        AgentTracePanel(steps: _steps),
                        const SizedBox(height: 20),

                        // Verdict Card shown after final step completes
                        if (_isFinished) ...[
                          GlassCard(
                            color: AppColors.success.withOpacity(0.2),
                            borderColor: AppColors.success,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.gavel, color: Colors.green, size: 24),
                                    const SizedBox(width: 10),
                                    Text(
                                      "AI VERDICT / فیصلہ",
                                      style: AppTextStyles.bodyBold.copyWith(color: Colors.green[800]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Our model audited your claim under Category '${widget.category}'. To ensure absolute customer fairness, we have generated a discount reimbursement coupon valid for any standard services.",
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "PROMO CODE",
                                            style: AppTextStyles.caption.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _promoCode,
                                            style: AppTextStyles.bodyBold.copyWith(fontSize: 16, color: Colors.green[800]),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.green[800],
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.copy, size: 14),
                                        label: const Text("Copy"),
                                        onPressed: _copyPromoCode,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  label: _isFinished ? "Back to Home / ہوم پیج" : "Arbitrating Dispute...",
                  onPressed: _isFinished
                      ? () {
                          context.go('/home');
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
