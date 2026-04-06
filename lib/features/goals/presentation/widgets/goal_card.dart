import 'package:flutter/material.dart';
import '../../../../core/extensions/string_ext.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency_info.dart';
import '../../../../shared/widgets/finn_card.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_status.dart';
import '../../domain/entities/goal_type.dart';
import '../../domain/usecases/predict_budget_exhaustion.dart';
import 'goal_progress_ring.dart';
import 'goal_status_badge.dart';
import 'goal_completion_card.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.transactions,
    required this.currency,
    required this.onDelete,
    this.onAddProgress,
  });

  final GoalEntity goal;
  final List<TransactionEntity> transactions;
  final CurrencyInfo currency;
  final VoidCallback onDelete;
  final VoidCallback? onAddProgress;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final progress = goal.progress(transactions, now);
    final status = goal.status(transactions, now);
    final color = Color(
      int.parse(goal.colorHex.replaceFirst('0x', ''), radix: 16),
    );

    final prediction = PredictBudgetExhaustion().call(goal, transactions);

    return Semantics(
      label: 'Goal: ${goal.title}. Progress: ${(progress.clamp(0.0, 1.0) * 100).round()}%. Status: ${status.name.titleCased}.',
      container: true,
      child: FinnCard(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: GoalProgressRing(
                    progress: progress.clamp(0.0, 1.0),
                    label: '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${goal.icon} ${goal.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      GoalStatusBadge(status: status),
                      const SizedBox(height: 10),
                      Text(
                        _subtitle(goal, transactions, now, currency),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Goal options',
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    } else if (value == 'progress') {
                      onAddProgress?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (goal.type == GoalType.savings && onAddProgress != null)
                      const PopupMenuItem(
                        value: 'progress',
                        child: Text('Update progress'),
                      ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (status == GoalStatus.atRisk || status == GoalStatus.failed) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                color: status == GoalStatus.failed
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.tertiary,
                semanticsLabel: 'Goal health indicator',
              ),
            ],
            if (prediction != null && (prediction.risk == ExhaustionRisk.high || prediction.risk == ExhaustionRisk.exceeded)) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prediction.risk == ExhaustionRisk.exceeded
                            ? 'Budget exceeded!'
                            : 'High risk! You might exhaust this budget in ${prediction.predictedExhaustionDate!.difference(now).inDays} days at your current burn rate.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (status == GoalStatus.completed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: GoalCompletionCard(goal: goal),
                      ),
                    );
                  },
                  icon: const Icon(Icons.stars_rounded),
                  label: const Text('Share achievement'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _subtitle(
    GoalEntity goal,
    List<TransactionEntity> transactions,
    DateTime now,
    CurrencyInfo currency,
  ) {
    final value = goal.displayValue(transactions, now);
    final target = goal.displayTarget();

    switch (goal.type) {
      case GoalType.savings:
      case GoalType.budget:
        return '${CurrencyFormatter.format(value, currency)} of ${CurrencyFormatter.format(target, currency)}';
      case GoalType.noSpend:
        return '${value.round()} of ${target.round()} days without ${goal.category?.label.toLowerCase()}';
      case GoalType.streak:
        return '${value.round()} of ${target.round()} days saved in a row';
    }
  }
}
