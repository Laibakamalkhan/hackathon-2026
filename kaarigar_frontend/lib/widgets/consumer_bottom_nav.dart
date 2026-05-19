import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/l10n/app_strings.dart';

enum ConsumerTab { chat, bookings, profile }

class ConsumerBottomNav extends ConsumerWidget {
  const ConsumerBottomNav({
    super.key,
    required this.active,
    required this.onTabSelected,
  });

  final ConsumerTab active;
  final ValueChanged<ConsumerTab> onTabSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.chat_bubble_outline, 'Chat', ConsumerTab.chat),
          _item(Icons.calendar_today_outlined, s.myBookings, ConsumerTab.bookings),
          _item(Icons.person_outline, 'Profile', ConsumerTab.profile),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, ConsumerTab tab) {
    final selected = active == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(tab),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
