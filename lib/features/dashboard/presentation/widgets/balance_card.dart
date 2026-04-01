import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency_info.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance, required this.currency});

  final double balance;
  final CurrencyInfo currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withValues(alpha: 0.76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(balance, currency),
            style: AppTextStyles.amountStyle(
              Theme.of(context).textTheme.displayMedium!,
            ).copyWith(color: colors.onPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            'A calm overview of everything you have logged so far.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}
