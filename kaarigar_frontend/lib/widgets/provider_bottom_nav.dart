import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

enum ProviderTab { home, jobs, earnings, history, profile }

class ProviderBottomNav extends StatelessWidget {
  const ProviderBottomNav({
    super.key,
    required this.active,
    required this.onTabSelected,
  });

  final ProviderTab active;
  final ValueChanged<ProviderTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        border: Border(top: BorderSide(color: AppColors.darkGlassBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(Icons.home_outlined, 'Home', ProviderTab.home),
            _item(Icons.work_outline, 'Jobs', ProviderTab.jobs),
            _item(Icons.account_balance_wallet_outlined, 'Pay', ProviderTab.earnings),
            _item(Icons.history, 'History', ProviderTab.history),
            _item(Icons.person_outline, 'Profile', ProviderTab.profile),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, ProviderTab tab) {
    final selected = active == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(tab),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.accentLavender : AppColors.darkTextSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.accentLavender : AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
