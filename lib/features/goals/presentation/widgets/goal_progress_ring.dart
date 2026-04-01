import 'package:flutter/material.dart';

import '../../../../shared/widgets/finn_progress_ring.dart';

class GoalProgressRing extends StatelessWidget {
  const GoalProgressRing({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
  });

  final double progress;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FinnProgressRing(
      progress: progress,
      color: color,
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
