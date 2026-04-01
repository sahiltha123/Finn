import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/currency_info.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';
import 'transaction_list_tile.dart';

class TransactionDayGroup extends StatelessWidget {
  const TransactionDayGroup({
    super.key,
    required this.date,
    required this.transactions,
    required this.currency,
    required this.onTap,
    required this.onDismissed,
  });

  final DateTime date;
  final List<TransactionEntity> transactions;
  final CurrencyInfo currency;
  final ValueChanged<TransactionEntity> onTap;
  final ValueChanged<TransactionEntity> onDismissed;

  @override
  Widget build(BuildContext context) {
    final subtotal = transactions.fold<double>(
      0,
      (total, item) => item.type == TransactionType.income
          ? total + item.amount
          : total - item.amount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormatter.transactionHeader(date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              CurrencyFormatter.format(subtotal, currency),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...transactions.map(
          (transaction) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey(transaction.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onDismissed: (_) => onDismissed(transaction),
              child: TransactionListTile(
                transaction: transaction,
                currency: currency,
                onTap: () => onTap(transaction),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
