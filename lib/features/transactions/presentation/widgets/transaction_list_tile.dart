import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency_info.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.currency,
    required this.onTap,
  });

  final TransactionEntity transaction;
  final CurrencyInfo currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.error;

    final amountText = '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount, currency)}';
    
    return Semantics(
      label: '${transaction.category.label}, ${isIncome ? "income" : "expense"} of $amountText. Notes: ${transaction.notes ?? "None"}',
      button: true,
      onTapHint: 'Edit transaction',
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Theme.of(context).cardTheme.color,
        leading: CircleAvatar(
          backgroundColor: transaction.category.color.withValues(alpha: 0.18),
          child: Icon(
            transaction.category.icon,
            color: transaction.category.color,
          ),
        ),
        title: Text(transaction.category.label),
        subtitle: Text(transaction.notes ?? 'No notes'),
        trailing: Text(
          amountText,
          style: AppTextStyles.amountStyle(
            Theme.of(context).textTheme.titleMedium!,
          ).copyWith(color: color),
        ),
      ),
    );
  }
}
