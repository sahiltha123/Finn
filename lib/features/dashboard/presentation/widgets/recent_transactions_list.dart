import 'package:flutter/material.dart';

import '../../../../shared/models/currency_info.dart';
import '../../../../shared/widgets/finn_card.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/widgets/transaction_list_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.currency,
    required this.onTap,
  });

  final List<TransactionEntity> transactions;
  final CurrencyInfo currency;
  final ValueChanged<TransactionEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return FinnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...transactions.map(
            (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TransactionListTile(
                transaction: transaction,
                currency: currency,
                onTap: () => onTap(transaction),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
