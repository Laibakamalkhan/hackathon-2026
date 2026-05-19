import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

abstract final class AppTypography {
  static TextStyle get fontFamily => GoogleFonts.nunito();

  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.nunito(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.nunito(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.nunito(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.nunito(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    bodySmall: GoogleFonts.nunito(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelSmall: GoogleFonts.nunito(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
  );

  static TextStyle darkTitle(double size) => GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: AppColors.textOnDark,
      );

  static TextStyle darkBody(double size, {double opacity = 0.55}) =>
      GoogleFonts.nunito(
        fontSize: size,
        color: AppColors.textOnDark.withValues(alpha: opacity),
      );
}
