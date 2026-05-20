import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../models/user_role.dart';
import '../../routes/app_routes.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/gradient_cta_button.dart';
import '../../widgets/onboarding_dots.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  AppLanguage _selected = AppLanguage.romanUrdu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const OnboardingDots(count: 3, activeIndex: 0),
                const SizedBox(height: 32),
                const Text(
                  'Apni Zubaan Chuniye',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'اپنی زبان چنیں',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                _langCard(AppLanguage.urdu, 'PK', 'اردو', isUrdu: true),
                const SizedBox(height: 12),
                _langCard(AppLanguage.romanUrdu, 'PK', 'Roman Urdu'),
                const SizedBox(height: 12),
                _langCard(AppLanguage.english, '🌐', 'English', isGlobe: true),
                const Spacer(),
                Text(
                  'KARIGAR sab samajhti hai — har zuban mein 🤗',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                GradientCtaButton(
                  label: 'Aagey Chalein →',
                  onPressed: () {
                    ref.read(userProfileProvider.notifier).state =
                        ref.read(userProfileProvider).copyWith(language: _selected);
                    context.go(AppRoutes.tutorial1);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _langCard(AppLanguage lang, String leading, String title, {bool isUrdu = false, bool isGlobe = false}) {
    final selected = _selected == lang;
    return GestureDetector(
      onTap: () => setState(() => _selected = lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLavender.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accentLavender : AppColors.glassBorder,
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: AppColors.glassShadow, blurRadius: 12, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isGlobe ? AppColors.accentLavender.withValues(alpha: 0.3) : AppColors.bgSecondary,
              child: Text(leading, style: TextStyle(fontSize: isGlobe ? 16 : 13, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isUrdu ? 20 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
