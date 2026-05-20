import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../models/user_role.dart';
import '../../routes/app_routes.dart';
import '../../widgets/ai_orb_logo.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_cta_button.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selected;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 32),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: const AiOrbLogo(size: 64),
                ),
                const SizedBox(height: 28),
                Text('Aap kaun hain?', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'How would you like to use ${s.appName}?',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _roleCard(
                        role: UserRole.seeker,
                        emoji: '🔍',
                        title: 'Kaam Karwana Hai',
                        subtitle: 'Book verified professionals',
                        accent: AppColors.accentLavender,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _roleCard(
                        role: UserRole.provider,
                        emoji: '🛠️',
                        title: 'Kaam Deta Hoon',
                        subtitle: 'Grow your income',
                        accent: AppColors.accentSand,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GradientCtaButton(
                  label: 'Aage Barho →',
                  enabled: _selected != null,
                  onPressed: () {
                    ref.read(userRoleProvider.notifier).state = _selected;
                    context.go(AppRoutes.phoneAuth);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required UserRole role,
    required String emoji,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    final selected = _selected == role;
    return GestureDetector(
      onTap: () => setState(() => _selected = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? accent : Colors.transparent, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.glassShadow, blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 24, backgroundColor: accent, child: Text(emoji, style: const TextStyle(fontSize: 22))),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
