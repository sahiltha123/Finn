import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/finn_card.dart';
import '../../domain/entities/health_score.dart';
import 'health_score_explanation_sheet.dart';

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({super.key, required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    Color gaugeColor = AppColors.catHealth;
    if (score.overallScore >= 85) gaugeColor = AppColors.catSavings; // green
    else if (score.overallScore >= 70) gaugeColor = AppColors.catTransport; // blueish
    else if (score.overallScore >= 50) gaugeColor = AppColors.catFood; // orangeish
    else gaugeColor = AppColors.catEntertain; // redish

    return Semantics(
      label: 'Financial Health Score: ${score.overallScore} out of 100. Category: ${score.tier}.',
      button: true,
      onTapHint: 'Show score breakdown',
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => HealthScoreExplanationSheet(score: score),
          );
        },
        child: FinnCard(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_heart_rounded, color: colors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text('Financial Health', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: score.overallScore / 100.0,
                        strokeWidth: 12,
                        backgroundColor: colors.surfaceContainerHighest,
                        color: gaugeColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${score.overallScore}',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          score.tier,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _buildMetric(context, 'Savings', '${score.savingsRateScore}/20'),
                   _buildMetric(context, 'Discipline', '${score.budgetDisciplineScore}/20'),
                   _buildMetric(context, 'Adherence', '${score.goalAdherenceScore}/20'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         Text(
           value,
           style: Theme.of(context).textTheme.titleMedium,
         ),
         Text(
           label,
           style: Theme.of(context).textTheme.bodySmall?.copyWith(
             color: Theme.of(context).colorScheme.onSurfaceVariant,
           ),
         ),
       ],
     );
  }
}
