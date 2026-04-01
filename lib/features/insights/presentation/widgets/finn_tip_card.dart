import 'package:flutter/material.dart';

import '../../../../shared/widgets/finn_card.dart';

class FinnTipCard extends StatelessWidget {
  const FinnTipCard({super.key, required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return FinnCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.lightbulb_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }
}
