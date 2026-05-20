import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.dark = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool dark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: active
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              dark ? AppColors.accentLavender : AppColors.textPrimary,
          foregroundColor:
              dark ? AppColors.textPrimary : AppColors.textOnDark,
          disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
