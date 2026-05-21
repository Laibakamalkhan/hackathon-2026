import 'package:flutter/material.dart';

/// AI Seekho design system — French Porcelain + glass morphism.
abstract final class AppColors {
  static const bgPrimary = Color(0xFFF5F4F7);
  static const bgSecondary = Color(0xFFEBDBD3);
  static const accentLavender = Color(0xFFBAC8E0);
  static const accentSand = Color(0xFFD0BEA3);
  static const accentSage = Color(0xFF8F917C);
  static const textPrimary = Color(0xFF1F1F1F);

  static const textSecondary = Color(0xFF7B7080);
  static const textOnDark = Color(0xFFF5F4F7);

  static const success = Color(0xFFA8D5B5);
  static const warning = Color(0xFFF5C97A);
  static const error = Color(0xFFE8A0A0);
  static const urgent = Color(0xFFF5B8A0);
  static const aiAccent = Color(0xFFBAC8E0);

  static const darkBg = Color(0xFF1F1F1F);
  static const darkCard = Color(0x0FFFFFFF);
  static const darkTextSecondary = Color(0x8CF5F4F7);

  static const glassFill = Color(0xA6FFFFFF);
  static const glassBorder = Color(0xCCFFFFFF);
  static const glassShadow = Color(0x0F1F1F1F);

  static const darkGlassFill = Color(0x0FFFFFFF);
  static const darkGlassBorder = Color(0x1AFFFFFF);

  static const userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgSecondary, accentSand],
  );

  static const orbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLavender, Colors.white],
  );

  static const shimmerGradient = LinearGradient(
    colors: [accentLavender, accentSand],
  );
}
