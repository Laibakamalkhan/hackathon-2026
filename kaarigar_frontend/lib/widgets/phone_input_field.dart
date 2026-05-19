import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';

/// Phone row: separate PK +92 chip + number field (Figma: phone auth.png).
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    this.hint = '3XX-XXXXXXX',
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.glassShadow, blurRadius: 12, offset: Offset(0, 2)),
            ],
          ),
          child: const Text(
            'PK +92',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: AppColors.glassShadow, blurRadius: 12, offset: Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 16, height: 1.2),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
