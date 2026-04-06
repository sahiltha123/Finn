import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency_info.dart';
import '../../../../shared/widgets/finn_card.dart';
import '../../../transactions/domain/entities/recurring_pattern.dart';
import '../../../transactions/domain/entities/transaction_category.dart';

class RecurringPatternTeaser extends StatelessWidget {
  const RecurringPatternTeaser({
    super.key,
    required this.patterns,
    required this.currency,
    required this.onDismiss,
  });

  final List<RecurringPattern> patterns;
  final CurrencyInfo currency;
  final ValueChanged<RecurringPattern> onDismiss;

  @override
  Widget build(BuildContext context) {
    if (patterns.isEmpty) return const SizedBox.shrink();

    final pattern = patterns.first;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label:
          'We noticed a recurring pattern. You often spend around ${CurrencyFormatter.format(pattern.estimatedAmount, currency)} on ${pattern.title}.',
      child: FinnCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detected Pattern',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => onDismiss(pattern),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: pattern.category.color.withValues(
                    alpha: 0.18,
                  ),
                  child: Icon(
                    pattern.category.icon,
                    color: pattern.category.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Roughly ${CurrencyFormatter.format(pattern.estimatedAmount, currency)} soon',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
