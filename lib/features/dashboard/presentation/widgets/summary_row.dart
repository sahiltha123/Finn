import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency_info.dart';
import '../../../../shared/widgets/finn_card.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.income,
    required this.expense,
    required this.currency,
  });

  final double income;
  final double expense;
  final CurrencyInfo currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryItem(
            label: 'Income',
            value: CurrencyFormatter.format(income, currency),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryItem(
            label: 'Expense',
            value: CurrencyFormatter.format(expense, currency),
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FinnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
