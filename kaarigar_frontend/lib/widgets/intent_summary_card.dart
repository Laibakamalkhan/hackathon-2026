import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/l10n/app_strings.dart';
import 'gradient_cta_button.dart';

class IntentTileData {
  const IntentTileData({
    required this.title,
    this.subtitle = '',
    required this.icon,
    required this.bgColor,
    this.onEdit,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final VoidCallback? onEdit;
}

/// In-chat intent summary — 2×2 tiles + confidence + actions (Figma: intent confirm.png).
class IntentSummaryCard extends ConsumerWidget {
  const IntentSummaryCard({
    super.key,
    required this.tiles,
    this.confidence = 0.94,
    this.showEditActions = false,
    this.onConfirm,
    this.onEdit,
    this.onRerun,
    this.onCancel,
  });

  final List<IntentTileData> tiles;
  final double confidence;
  final bool showEditActions;
  final VoidCallback? onConfirm;
  final VoidCallback? onEdit;
  final VoidCallback? onRerun;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: const [
          BoxShadow(color: AppColors.glassShadow, blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: tiles.map(_IntentTile.new).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.success),
              const SizedBox(width: 6),
              Text('AI Confidence', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                'Bohot zyada yakeen',
                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: AppColors.bgSecondary,
              color: AppColors.success,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${(confidence * 100).round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
          if (showEditActions) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('✕ Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: GradientCtaButton(label: 'Re-run AI Match →', onPressed: onRerun)),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Bilkul Sahi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success.withValues(alpha: 0.45),
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Badlo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GradientCtaButton(label: s.confirmAndMatch, onPressed: onConfirm),
          ],
        ],
      ),
    );
  }
}

class _IntentTile extends StatelessWidget {
  const _IntentTile(this.data);
  final IntentTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, size: 20, color: AppColors.textPrimary.withValues(alpha: 0.7)),
              const Spacer(),
              Text(data.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              if (data.subtitle.isNotEmpty)
                Text(data.subtitle, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.check_circle, size: 16, color: AppColors.success.withValues(alpha: 0.9)),
          ),
          if (data.onEdit != null)
            Positioned(
              top: 0,
              right: 20,
              child: GestureDetector(
                onTap: data.onEdit,
                child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
