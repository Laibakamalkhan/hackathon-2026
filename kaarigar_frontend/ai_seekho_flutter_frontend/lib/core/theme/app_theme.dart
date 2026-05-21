import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        colorScheme: ColorScheme.light(
          primary: AppColors.accentLavender,
          secondary: AppColors.accentSand,
          surface: AppColors.bgPrimary,
          error: AppColors.error,
          onPrimary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: AppTypography.textTheme,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentLavender,
          surface: AppColors.darkBg,
          onSurface: AppColors.textOnDark,
        ),
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.textOnDark,
          displayColor: AppColors.textOnDark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      );
}
