import 'package:flutter/material.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';

class TraceStep {
  final String title;
  final String titleUrdu;
  final String description;
  final String descriptionUrdu;
  final String status; // 'pending', 'running', 'completed', 'failed'

  const TraceStep({
    required this.title,
    required this.titleUrdu,
    required this.description,
    required this.descriptionUrdu,
    required this.status,
  });
}

class AgentTracePanel extends StatelessWidget {
  final List<TraceStep> steps;

  const AgentTracePanel({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.textPrimary, size: 24),
              const SizedBox(width: 8),
              Text(
                "AI Agent Brain Trace",
                style: AppTextStyles.heading2.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Progressive multi-agent routing timeline",
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final step = steps[index];
              return _buildStepRow(step);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(TraceStep step) {
    Color indicatorColor;
    Widget statusWidget;

    switch (step.status) {
      case 'completed':
        indicatorColor = AppColors.success;
        statusWidget = const Icon(Icons.check_circle, color: Colors.green, size: 20);
        break;
      case 'running':
        indicatorColor = AppColors.lavender;
        statusWidget = const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
          ),
        );
        break;
      case 'failed':
        indicatorColor = AppColors.error;
        statusWidget = const Icon(Icons.error, color: Colors.red, size: 20);
        break;
      case 'pending':
      default:
        indicatorColor = AppColors.textSecondary.withOpacity(0.3);
        statusWidget = Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
        );
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: statusWidget,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: step.status == 'pending'
                            ? AppColors.textSecondary.withOpacity(0.6)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    step.titleUrdu,
                    style: AppTextStyles.urdu.copyWith(
                      fontSize: 13,
                      color: step.status == 'pending'
                          ? AppColors.textSecondary.withOpacity(0.6)
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                step.description,
                style: AppTextStyles.caption.copyWith(
                  color: step.status == 'pending'
                      ? AppColors.textSecondary.withOpacity(0.4)
                      : AppColors.textSecondary,
                ),
              ),
              if (step.descriptionUrdu.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  step.descriptionUrdu,
                  style: AppTextStyles.urdu.copyWith(
                    fontSize: 12,
                    color: step.status == 'pending'
                        ? AppColors.textSecondary.withOpacity(0.4)
                        : AppColors.textSecondary,
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
