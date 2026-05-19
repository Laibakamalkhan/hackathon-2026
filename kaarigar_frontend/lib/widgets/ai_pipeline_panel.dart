import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants/app_colors.dart';

class AgentStage {
  const AgentStage({
    required this.label,
    required this.detail,
    required this.color,
    required this.icon,
  });

  final String label;
  final String detail;
  final Color color;
  final IconData icon;
}

class AiPipelinePanel extends StatelessWidget {
  const AiPipelinePanel({
    super.key,
    required this.stages,
    required this.currentIndex,
    required this.progress,
  });

  final List<AgentStage> stages;
  final int currentIndex;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xE01F1F1F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentLavender.withValues(alpha: 0.35), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentLavender.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🤖', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Multi-Agent Pipeline',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '${currentIndex + 1}/${stages.length}',
                style: const TextStyle(color: AppColors.success, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 5,
              backgroundColor: Colors.white10,
              color: AppColors.accentLavender,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(stages.length, (i) {
            final stage = stages[i];
            final completed = i < currentIndex;
            final active = i == currentIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StageRow(
                stage: stage,
                completed: completed,
                active: active,
              ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: -0.05, end: 0),
            );
          }),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.completed,
    required this.active,
  });

  final AgentStage stage;
  final bool completed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.12)
            : completed
                ? AppColors.success.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? stage.color
              : completed
                  ? AppColors.success.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? stage.color
                  : active
                      ? stage.color.withValues(alpha: 0.25)
                      : AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : active
                    ? Icon(stage.icon, color: stage.color, size: 18)
                    : Icon(stage.icon, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stage.label,
                        style: TextStyle(
                          color: completed || active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (active)
                      Row(
                        children: List.generate(
                          3,
                          (i) => Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(left: 3),
                            decoration: BoxDecoration(
                              color: stage.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  stage.detail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
