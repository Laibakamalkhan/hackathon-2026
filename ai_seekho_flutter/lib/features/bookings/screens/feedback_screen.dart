import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

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

  // Negative keywords that trigger immediate AI dispute arbitration
  final List<String> _disputeKeywords = [
    "kharab", "cheat", "scam", "damaged", "broken", "chori", "tampered",
    "bad", "terrible", "worst", "fraud", "extra money", "loot", "ziada paise"
  ];

  void _submitFeedback() {
    final comment = _commentController.text.toLowerCase();
    
    // Smart Routing Logic: Low rating (1 or 2 stars) or comment contains negative dispute words
    bool isDispute = _rating <= 2;
    for (var word in _disputeKeywords) {
      if (comment.contains(word)) {
        isDispute = true;
        break;
      }
    }

    if (isDispute) {
      // Auto routing to automated AI Dispute center
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚨 Low satisfaction detected. Initiating automated AI Dispute Mediation..."),
          backgroundColor: AppColors.error,
        ),
      );
      context.push(
        '/dispute?id=${widget.bookingId}&rating=$_rating&reason=${Uri.encodeComponent(_commentController.text)}',
      );
    } else {
      // Direct successful completion flow routing to booking history
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thank you for your rating! feedback logged successfully."),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/history');
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
                const Text(
                  "Rate Your Service",
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  "کاریگر کی ریٹنگ کریں",
                  style: AppTextStyles.urdu.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Star Selection Card
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      const Text(
                        "How was your repair experience?",
                        style: AppTextStyles.bodyBold,
                      ),
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
                            onPressed: () {
                              setState(() {
                                _rating = currentStar;
                              });
                            },
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

                // Comments input box
                const Text(
                  "Comments / تاثرات",
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Share your experience or note any issues... (e.g. extra charges, bad behavior)",
                      border: InputBorder.none,
                    ),
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(height: 36),

                PrimaryButton(
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
