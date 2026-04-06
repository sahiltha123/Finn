import 'package:flutter/material.dart';
import '../../domain/entities/health_score.dart';

class HealthScoreExplanationSheet extends StatelessWidget {
  const HealthScoreExplanationSheet({super.key, required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.analytics_rounded, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'How your score of ${score.overallScore} is calculated',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildScoreRow(context, 'Savings Rate', score.savingsRateScore, 'Target: 20%+ of income'),
          _buildScoreRow(context, 'Goal Adherence', score.goalAdherenceScore, '% of active goals on track'),
          _buildScoreRow(context, 'Budget Discipline', score.budgetDisciplineScore, 'Staying within your limits'),
          _buildScoreRow(context, 'Consistency', score.spendingConsistencyScore, 'Weekly spending variance'),
          _buildScoreRow(context, 'Income Growth', score.incomeGrowthScore, 'MoM income trending'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: colors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    score.primaryInsight,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(BuildContext context, String label, int points, String sub) {
    final colors = Theme.of(context).colorScheme;
    final progress = points / 20.0;
    
    Color color = colors.error;
    if (points >= 17) color = Colors.green;
    else if (points >= 14) color = Colors.blue;
    else if (points >= 10) color = Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text('$points/20', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(sub, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.surfaceContainerHighest,
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
