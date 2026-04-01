import 'package:flutter/material.dart';

import '../../domain/entities/goal_status.dart';

class GoalStatusBadge extends StatelessWidget {
  const GoalStatusBadge({super.key, required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      GoalStatus.onTrack => Theme.of(context).colorScheme.secondary,
      GoalStatus.atRisk => Theme.of(context).colorScheme.tertiary,
      GoalStatus.completed => Theme.of(context).colorScheme.primary,
      GoalStatus.failed => Theme.of(context).colorScheme.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
