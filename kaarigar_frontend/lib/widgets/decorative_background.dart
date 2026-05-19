import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({
    super.key,
    this.dark = false,
    this.child,
  });

  final bool dark;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: dark ? AppColors.darkBg : AppColors.bgPrimary),
        Positioned(
          top: 40,
          left: -80,
          child: _blob(AppColors.accentLavender, dark ? 0.1 : 0.25),
        ),
        Positioned(
          top: 0,
          right: -80,
          child: _blob(AppColors.bgSecondary, dark ? 0.1 : 0.25),
        ),
        if (!dark)
          Positioned(
            bottom: 120,
            left: MediaQuery.sizeOf(context).width / 2 - 100,
            child: _blob(AppColors.accentSand, 0.25),
          ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }

  Widget _blob(Color color, double opacity) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
