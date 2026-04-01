import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency_info.dart';
import '../../../../shared/widgets/finn_card.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_status.dart';
import '../../domain/entities/goal_type.dart';
import 'goal_progress_ring.dart';
import 'goal_status_badge.dart';

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

    return FinnCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GoalProgressRing(
                progress: progress.clamp(0.0, 1.0),
                label: '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                color: color,
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
            ),
          ],
        ],
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
