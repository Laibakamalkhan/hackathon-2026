import 'package:flutter/material.dart';
import 'package:ai_seekho_flutter/app/theme.dart';

class ConfidenceBadge extends StatelessWidget {
  final double score; // Expected range: 0.0 to 1.0 (e.g. 0.92)

  const ConfidenceBadge({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;
    IconData icon;

    if (score >= 0.85) {
      badgeColor = AppColors.success;
      label = "High Trust Match";
      icon = Icons.verified_user;
    } else if (score >= 0.65) {
      badgeColor = AppColors.warning;
      label = "Moderate Match";
      icon = Icons.gpp_maybe;
    } else {
      badgeColor = AppColors.error;
      label = "Low Confidence Match";
      icon = Icons.gpp_bad;
    }

    final percentage = (score * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(
          color: badgeColor.withOpacity(0.4),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 14),
          const SizedBox(width: 6),
          Text(
            "$label ($percentage%)",
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
