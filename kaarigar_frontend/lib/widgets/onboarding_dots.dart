import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return Container(
          width: active ? 8 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.textPrimary : Colors.transparent,
            border: Border.all(
              color: AppColors.textPrimary,
              width: active ? 0 : 1.5,
            ),
          ),
        );
      }),
    );
  }
}
