import 'package:flutter/material.dart';

import '../../../../shared/widgets/finn_card.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/presentation/widgets/goal_status_badge.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class ActiveGoalTeaser extends StatelessWidget {
  const ActiveGoalTeaser({
    super.key,
    required this.goal,
    required this.transactions,
  });

  final GoalEntity? goal;
  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return const SizedBox.shrink();
    }

    final status = goal!.status(transactions, DateTime.now());
    final progress = goal!
        .progress(transactions, DateTime.now())
        .clamp(0.0, 1.0);

    return FinnCard(
      child: Row(
        children: [
          CircleAvatar(radius: 24, child: Text(goal!.icon)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal!.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                GoalStatusBadge(status: status),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
