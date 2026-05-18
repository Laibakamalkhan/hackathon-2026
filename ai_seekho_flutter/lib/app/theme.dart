import 'package:flutter/material.dart';

class AppColors {
  // === BACKGROUNDS ===
  static const bgPrimary      = Color(0xFFF5F4F7); // French Porcelain — consumer screens
  static const bgSecondary    = Color(0xFFEBDBD3); // Hudson — warm blush beige
  static const bgDark         = Color(0xFF1F1F1F); // Umbra — provider screens

  // === ACCENT COLORS ===
  static const lavender       = Color(0xFFBAC8E0); // Penna — AI elements, primary actions
  static const sand           = Color(0xFFD0BEA3); // Country Rubble — warm tan
  static const sage           = Color(0xFF8F917C); // Farmer's Market — muted olive

  // === TEXT ===
  static const textPrimary    = Color(0xFF1F1F1F); // near-black
  static const textSecondary  = Color(0xFF7B7080); // muted warm grey
  static const textOnDark     = Color(0xFFF5F4F7); // light on dark backgrounds

  // === FUNCTIONAL ===
  static const success        = Color(0xFFA8D5B5); // soft sage green
  static const warning        = Color(0xFFF5C97A); // warm amber
  static const error          = Color(0xFFE8A0A0); // soft coral
  static const urgent         = Color(0xFFF5B8A0); // warm peach-coral

  // === GRADIENTS ===
  static const primaryGradient = LinearGradient(
    colors: [lavender, sand],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const darkCardBg = Color(0x0FFFFFFF); // rgba(255,255,255,0.06) — provider cards
}

class AppRadius {
  static const double card      = 24.0;   // cards
  static const double cardLarge = 28.0;   // bottom sheets, large cards
  static const double button    = 50.0;   // rounded-full buttons
  static const double input     = 16.0;   // text inputs
  static const double chip      = 50.0;   // filter chips
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 26,
    fontWeight: FontWeight.w800,  // extrabold
    color: AppColors.textPrimary,
  );
  
  static const heading2 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  
  static const bodyBold = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  static const caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  static const urdu = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const buttonLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
