import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_durations.dart';
import '../../core/l10n/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../widgets/ai_orb_logo.dart';
import '../../widgets/decorative_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(AppDurations.splash, () {
      if (mounted) context.go(AppRoutes.languageSelect);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      body: DecorativeBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AiOrbLogo()
                  .animate()
                  .scale(begin: const Offset(0.8, 0.8), duration: 600.ms)
                  .fadeIn(),
              const SizedBox(height: 32),
              Text(
                'KARIGAR',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w900,
                    ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                s.taglineUrdu,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 20,
                    ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 8),
              Text(
                s.taglineRoman,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 48),
              SizedBox(
                width: 180,
                height: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    backgroundColor: AppColors.bgSecondary,
                    color: AppColors.accentLavender,
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
