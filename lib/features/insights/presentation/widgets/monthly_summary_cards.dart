import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency_info.dart';
import '../../../../shared/widgets/finn_card.dart';

class MonthlySummaryCards extends StatelessWidget {
  const MonthlySummaryCards({
    super.key,
    required this.income,
    required this.expense,
    required this.savingsRate,
    required this.currency,
  });

  final double income;
  final double expense;
  final double savingsRate;
  final CurrencyInfo currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Income',
            value: CurrencyFormatter.format(income, currency, compact: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Expense',
            value: CurrencyFormatter.format(expense, currency, compact: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Savings',
            value: '${(savingsRate * 100).round()}%',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FinnCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
