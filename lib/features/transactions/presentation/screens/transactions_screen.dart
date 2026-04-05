import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/finn_empty_state.dart';
import '../../../../shared/widgets/finn_error_widget.dart';
import '../../../../shared/widgets/finn_shimmer_list.dart';
import '../../../../shared/widgets/finn_snackbar.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/transaction_providers.dart';
import '../widgets/add_edit_transaction_sheet.dart';
import '../widgets/transaction_day_group.dart';
import '../widgets/transaction_filter_bar.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  TransactionType? _selectedType;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final filterTransactions = ref.watch(filterTransactionsUseCaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: transactionsAsync.when(
        data: (transactions) {
          final filtered = filterTransactions(
            transactions,
            type: _selectedType,
            query: _query,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search category or note',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TransactionFilterBar(
                selectedType: _selectedType,
                onTypeChanged: (value) => setState(() => _selectedType = value),
              ),
              const SizedBox(height: 24),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: FinnEmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: AppStrings.noTransactions,
                    message:
                        'Start with one expense or income to build your money timeline.',
                  ),
                )
              else
                ..._groupTransactions(filtered).entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: TransactionDayGroup(
                      date: entry.key,
                      transactions: entry.value,
                      currency: currency,
                      onTap: _editTransaction,
                      onDismissed: _deleteTransaction,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const FinnShimmerList(itemCount: 6),
        error: (error, stackTrace) => FinnErrorWidget(
          message: 'Failed to load transactions.',
          onRetry: () => ref.invalidate(transactionsProvider),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _query = value);
    });
  }

  Map<DateTime, List<TransactionEntity>> _groupTransactions(
    List<TransactionEntity> transactions,
  ) {
    final grouped = <DateTime, List<TransactionEntity>>{};
    for (final transaction in transactions) {
      final key = transaction.date.startOfDay;
      grouped.putIfAbsent(key, () => <TransactionEntity>[]).add(transaction);
    }
    return grouped;
  }

  void _editTransaction(TransactionEntity transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddEditTransactionSheet(transaction: transaction),
    );
  }

  Future<void> _deleteTransaction(TransactionEntity transaction) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await HapticFeedback.mediumImpact();
    final result = await ref.read(deleteTransactionUseCaseProvider)(
      uid: user.uid,
      transactionId: transaction.id,
    );

    result.fold(
      (failure) => showFinnSnackBar(context, message: failure.message),
      (_) {
        showFinnSnackBar(
          context,
          message: 'Transaction deleted',
          actionLabel: 'Undo',
          onAction: () {
            ref.read(addTransactionUseCaseProvider)(
              uid: user.uid,
              transaction: transaction,
            );
          },
        );
      },
    );
  }
}
