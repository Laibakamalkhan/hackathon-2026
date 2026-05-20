import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/gradient_cta_button.dart';
import '../../widgets/onboarding_dots.dart';

class Tutorial1Screen extends StatelessWidget {
  const Tutorial1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialScaffold(
      pageIndex: 1,
      illustration: _FactorGridIllustration(),
      title: 'AI Dhundhega Best Option',
      subtitle: '8 factors se sab se behtar service provider choose kiya jata hai',
      onSkip: () => context.go(AppRoutes.roleSelect),
      onNext: () => context.go(AppRoutes.tutorial2),
      nextLabel: 'Agla →',
      child: _FactorGrid(),
    );
  }
}

class Tutorial2Screen extends StatelessWidget {
  const Tutorial2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialScaffold(
      pageIndex: 2,
      illustration: _BookTrackIllustration(),
      title: 'Book, Track, Aur Rate!',
      subtitle: 'Confirmation, reminders, aur feedback — sab kuch automatic',
      onSkip: () => context.go(AppRoutes.roleSelect),
      onNext: () => context.go(AppRoutes.roleSelect),
      nextLabel: 'Shuru Karein! 🚀',
      footer: 'KARIGAR mein khush amdeed!',
      child: _StatusRow(),
    );
  }
}

class _TutorialScaffold extends StatelessWidget {
  const _TutorialScaffold({
    required this.pageIndex,
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onSkip,
    required this.onNext,
    required this.nextLabel,
    this.footer,
  });

  final int pageIndex;
  final Widget illustration;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final String nextLabel;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    OnboardingDots(count: 3, activeIndex: pageIndex),
                    TextButton(onPressed: onSkip, child: const Text('Skip')),
                  ],
                ),
                const SizedBox(height: 16),
                illustration,
                const SizedBox(height: 24),
                Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                child,
                const Spacer(),
                if (footer != null) ...[
                  Text(footer!, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                GradientCtaButton(label: nextLabel, onPressed: onNext),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FactorGridIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgSecondary,
      ),
      child: const Center(child: Text('⭐', style: TextStyle(fontSize: 48))),
    );
  }
}

class _BookTrackIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [AppColors.success.withValues(alpha: 0.4), AppColors.success.withValues(alpha: 0.15)],
        ),
      ),
      child: const Center(child: Text('📅', style: TextStyle(fontSize: 48))),
    );
  }
}

class _FactorGrid extends StatelessWidget {
  static const _factors = [
    ('📍', 'Distance'),
    ('⭐', 'Rating'),
    ('⏰', 'Punctuality'),
    ('🔧', 'Specialization'),
    ('💰', 'Price Fit'),
    ('❌', 'Cancellation Rate'),
    ('💬', 'Reviews'),
    ('📅', 'Availability'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: _factors
          .map(
            (f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Text(f.$1),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f.$2, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatusRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = ['Booked', 'Reminded', 'En Route', 'Arrived', 'Done'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(steps.length, (i) {
        final done = i < 3;
        return Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: done ? AppColors.textPrimary : Colors.white,
              child: Icon(
                Icons.check,
                size: 18,
                color: done ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(steps[i], style: const TextStyle(fontSize: 10)),
          ],
        );
      }),
    );
  }
}
