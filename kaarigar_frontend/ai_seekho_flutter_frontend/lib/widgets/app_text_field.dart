import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.prefix,
    this.onChanged,
    this.dark = false,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscureText;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: dark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(
            color: dark ? AppColors.textOnDark : AppColors.textPrimary,
            fontSize: 16,
          ),
          inputFormatters: maxLength != null
              ? [LengthLimitingTextInputFormatter(maxLength)]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: dark
                  ? AppColors.textOnDark.withValues(alpha: 0.4)
                  : AppColors.textSecondary,
            ),
            prefixIcon: prefix,
            counterText: '',
            filled: true,
            fillColor: dark
                ? AppColors.darkGlassFill
                : AppColors.glassFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
              borderSide: BorderSide(
                color: dark
                    ? AppColors.darkGlassBorder
                    : AppColors.glassBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
              borderSide: BorderSide(
                color: dark
                    ? AppColors.darkGlassBorder
                    : AppColors.glassBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
              borderSide: const BorderSide(color: AppColors.accentLavender, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
