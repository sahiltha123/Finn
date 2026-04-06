import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency_info.dart';

import '../../../../shared/widgets/glass_container.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance, required this.currency});

  final double balance;
  final CurrencyInfo currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Net balance: ${CurrencyFormatter.format(balance, currency)}',
      container: true,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(30),
        backgroundOpacity: 0.25,
        borderOpacity: 0.3,
        blurSigma: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Net balance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.8),
              ),
              semanticsLabel: '', // Hide from screen reader as parent handles it
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(balance, currency),
              style: AppTextStyles.amountStyle(
                Theme.of(context).textTheme.displayMedium!,
              ).copyWith(color: colors.onSurface),
              semanticsLabel: '',
            ),
            const SizedBox(height: 10),
            Text(
              'A calm overview of everything you have logged so far.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.78),
              ),
              semanticsLabel: '',
            ),
          ],
        ),
      ),
    );
  }
}
