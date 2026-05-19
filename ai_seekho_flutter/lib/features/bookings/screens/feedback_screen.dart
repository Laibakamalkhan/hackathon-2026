import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';
import 'package:ai_seekho_flutter/core/network/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  final String bookingId;

  const FeedbackScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  // Negative keywords that trigger immediate AI dispute arbitration
  final List<String> _disputeKeywords = [
    "kharab", "cheat", "scam", "damaged", "broken", "chori", "tampered",
    "bad", "terrible", "worst", "fraud", "extra money", "loot", "ziada paise"
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final comment = _commentController.text.toLowerCase().trim();

    // Smart Routing: Low rating (1-2★) or negative keywords → dispute
    bool isDispute = _rating <= 2;
    for (var word in _disputeKeywords) {
      if (comment.contains(word)) {
        isDispute = true;
        break;
      }
    }

    if (isDispute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚨 Low satisfaction detected. Routing to AI Dispute Mediation..."),
          backgroundColor: AppColors.error,
        ),
      );
      context.push(
        '/dispute?id=${widget.bookingId}&rating=$_rating&reason=${Uri.encodeComponent(_commentController.text)}',
      );
      return;
    }

    // Submit feedback to real API
    setState(() => _isSubmitting = true);
    try {
      final result = await apiService.submitFeedback(
        bookingId: widget.bookingId,
        rating: _rating.toDouble(),
        comment: _commentController.text.trim(),
        userId: 'user_demo_001',
      );

      if (!mounted) return;

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kuch masla hua, dobara koshish karein."),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Shukriya! Aap ka feedback submit ho gaya."),
            backgroundColor: AppColors.success,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go('/history');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: ${e.toString().substring(0, 50)}"),
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
                const Text("Rate Your Service", style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Text("کاریگر کی ریٹنگ کریں", style: AppTextStyles.urdu.copyWith(fontSize: 16)),
                const SizedBox(height: 24),

                // Star Selection Card
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      const Text("How was your repair experience?", style: AppTextStyles.bodyBold),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final currentStar = index + 1;
                          return IconButton(
                            icon: Icon(
                              currentStar <= _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 40,
                            ),
                            onPressed: () => setState(() => _rating = currentStar),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _rating <= 2
                            ? "Unhappy / مطمئن نہیں"
                            : _rating == 3
                                ? "Neutral / مناسب"
                                : "Excellent / زبردست",
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Comments / تاثرات", style: AppTextStyles.bodyBold),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Share your experience or note any issues...",
                      border: InputBorder.none,
                    ),
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(height: 36),

                _isSubmitting
                    ? const Center(child: CircularProgressIndicator(color: AppColors.lavender))
                    : PrimaryButton(
                        label: "Submit Feedback / جمع کریں",
                        onPressed: _submitFeedback,
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
