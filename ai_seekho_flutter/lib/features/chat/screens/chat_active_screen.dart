import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

/// ChatActiveScreen — removed fake Timer.periodic step progression.
/// Now immediately shows the user query and routes to intent-confirm.
/// The real orchestration happens in IntentConfirmScreen via the backend.
class ChatActiveScreen extends StatelessWidget {
  final String query;

  const ChatActiveScreen({super.key, required this.query});

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
                const Text("AI Matchmaking Pipeline", style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Text("اے آئی میچ میکنگ پائپ لائن",
                    style: AppTextStyles.urdu.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    '"$query"',
                    style: AppTextStyles.bodyBold.copyWith(
                        fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.lavender),
                        SizedBox(height: 20),
                        Text(
                          "Connecting to AI Seekho Agents...",
                          style: AppTextStyles.bodyBold,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "اے آئی ایجنٹس سے رابطہ ہو رہا ہے...",
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: "View Match Results / نتائج دیکھیں",
                  onPressed: () => context.push(
                    '/intent-confirm?query=${Uri.encodeComponent(query)}',
                  ),
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
