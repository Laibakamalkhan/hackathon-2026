import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final String providerName;
  final String totalPrice;

  const BookingConfirmedScreen({
    super.key,
    required this.providerName,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Animated glowing success tick circle
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withOpacity(0.2),
                      border: Border.all(color: AppColors.success, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Booking Confirmed!",
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "بکنگ کنفرم ہو گئی ہے",
                  style: AppTextStyles.urdu.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Your request has been successfully dispatched to the specialist. They are preparing tools now.",
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Booking Info Summary Card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSummaryRow("Technician / کاریگر", providerName),
                      const SizedBox(height: 12),
                      _buildSummaryRow("Total Amount / کل رقم", totalPrice),
                      const SizedBox(height: 12),
                      _buildSummaryRow("ETA / آمد کا وقت", "25 - 35 Mins"),
                      const SizedBox(height: 12),
                      _buildSummaryRow("Address / پتہ", "G-13/2 Street 5, Islamabad"),
                    ],
                  ),
                ),
                const Spacer(),

                PrimaryButton(
                  label: "Track Booking / بکنگ ٹریک کریں",
                  onPressed: () {
                    // Navigate to details screen with secure arguments
                    context.push(
                      '/booking-detail?id=BK-88F9A&provider=${Uri.encodeComponent(providerName)}&price=${Uri.encodeComponent(totalPrice)}',
                    );
                  },
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    "Back to Home / ہوم پیج",
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            val,
            style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
