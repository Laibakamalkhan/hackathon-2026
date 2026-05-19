import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';
import 'package:ai_seekho_flutter/core/network/api_service.dart';

class DisputeScreen extends StatefulWidget {
  final String bookingId;
  final String? initialReason;

  const DisputeScreen({
    super.key,
    required this.bookingId,
    this.initialReason,
  });

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  String _selectedCategory = "Overcharging";
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  // Maps UI display value → backend dispute_type
  final Map<String, String> _categoryMap = {
    "Overcharging": "price",
    "Incomplete Work": "quality",
    "No Show": "no_show",
    "Late / Overrun": "overrun",
    "Cancellation": "cancellation",
    "Property Damage": "quality",
    "Unprofessional Behavior": "quality",
  };

  final List<String> _displayCategories = [
    "Overcharging / زیادہ پیسے",
    "Incomplete Work / نامکمل کام",
    "No Show / نہیں آیا",
    "Late / Overrun / دیر سے آیا",
    "Cancellation / منسوخی",
    "Property Damage / نقصان",
    "Unprofessional Behavior / غلط رویہ",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialReason != null) {
      _detailsController.text = widget.initialReason!;
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String get _backendDisputeType =>
      _categoryMap[_selectedCategory] ?? "quality";

  Future<void> _submitDispute() async {
    if (_detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pehle shikayat ki tafseelaat likhein.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await apiService.resolveDispute(
        bookingId: widget.bookingId,
        disputeType: _backendDisputeType,
        description: _detailsController.text.trim(),
        userId: 'user_demo_001',
      );

      if (!mounted) return;

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${result['error']}"),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        // Navigate to resolution screen with real data from GuardianAgent
        context.push('/dispute-resolution', extra: {
          'bookingId': widget.bookingId,
          'category': _selectedCategory,
          'details': _detailsController.text.trim(),
          'resolution': result['resolution'] ?? {},
          'escalation_needed': result['escalation_needed'] ?? false,
          'escalation_reason': result['escalation_reason'],
          'user_message_urdu': result['user_message_urdu'] ?? '',
          'user_message_en': result['user_message_en'] ?? '',
          'provider_action': result['provider_action'] ?? 'none',
          'trace_events': result['trace_events'] ?? [],
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error — please retry: ${e.toString().substring(0, 40)}"),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
                const Text("AI Dispute Center", style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Text("اے آئی تنازعات کا مرکز",
                    style: AppTextStyles.urdu.copyWith(fontSize: 16)),
                const SizedBox(height: 20),

                // Category selector
                const Text("Dispute Type / شکایت کی قسم", style: AppTextStyles.bodyBold),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                      items: _displayCategories.map((String label) {
                        final key = label.split(' / ')[0];
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                const Text("Write Details / تفصیلات لکھیں", style: AppTextStyles.bodyBold),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _detailsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Explain what went wrong so our AI can evaluate...",
                      border: InputBorder.none,
                    ),
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(height: 20),

                // Evidence photos (honest placeholder)
                const Text("Evidence Photos / ثبوت", style: AppTextStyles.bodyBold),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 32, color: AppColors.lavender),
                            const SizedBox(height: 12),
                            const Text(
                              "Photo upload coming soon!",
                              style: AppTextStyles.bodyBold,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Evidence photo attachment will be available in the next release. "
                              "Your text description will be used for AI evaluation.",
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.add_a_photo, size: 32, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to Upload (Coming Soon)",
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                _isSubmitting
                    ? const Center(child: CircularProgressIndicator(color: AppColors.lavender))
                    : PrimaryButton(
                        label: "Submit to AI Mediation / شکایت درج کریں",
                        onPressed: _submitDispute,
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
