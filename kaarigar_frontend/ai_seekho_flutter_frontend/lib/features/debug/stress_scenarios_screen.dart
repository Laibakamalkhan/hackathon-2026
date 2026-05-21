import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../routes/app_routes.dart';

class StressScenariosScreen extends ConsumerWidget {
  const StressScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug Mode Only')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Scenarios Debug'),
        backgroundColor: AppColors.accentLavender,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Demo Triggers (Judge Scenarios)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _ScenarioButton(
            title: '1. No Providers (Obscure + Urgent)',
            description: 'Triggers empty provider list response.',
            icon: Icons.search_off,
            onTap: () {
              ref.read(chatMessageProvider.notifier).state =
                  'Mujhe abhi ke abhi spaceship repair wala chahiye';
              context.push(AppRoutes.chatActive);
            },
          ),
          const SizedBox(height: 12),
          _ScenarioButton(
            title: '2. Provider Conflict (Double Booking)',
            description: 'Test this by booking a slot that is known to fail.',
            icon: Icons.event_busy,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Run a normal flow but choose a conflicting slot.'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ScenarioButton(
            title: '3. Low Confidence (Vague Query)',
            description: 'Triggers clarification flow.',
            icon: Icons.help_outline,
            onTap: () {
              ref.read(chatMessageProvider.notifier).state =
                  'kuch theek nahi chal raha';
              context.push(AppRoutes.chatActive);
            },
          ),
          const SizedBox(height: 12),
          _ScenarioButton(
            title: '4. Dispute (Price Disagreement)',
            description: 'Navigate to disputes for a test booking.',
            icon: Icons.gavel,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Go to Post Booking -> Submit Dispute for an existing booking.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScenarioButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ScenarioButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
