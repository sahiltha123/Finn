import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/finn_category_chip.dart';
import '../../../../shared/widgets/finn_shimmer_list.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/widgets/add_edit_transaction_sheet.dart';
import '../../presentation/providers/dashboard_providers.dart';
import '../widgets/active_goal_teaser.dart';
import '../widgets/balance_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/spending_chart.dart';
import '../widgets/summary_row.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  TransactionCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting()),
            Text(
              user?.name.split(' ').first.titleCased ?? 'there',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.profile),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) {
          final visibleTransactions = _selectedCategory == null
              ? summary.recentTransactions
              : summary.recentTransactions
                    .where((item) => item.category == _selectedCategory)
                    .toList();
          final categories = summary.recentTransactions
              .map((item) => item.category)
              .toSet()
              .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BalanceCard(balance: summary.totalBalance, currency: currency),
              const SizedBox(height: 16),
              SummaryRow(
                income: summary.monthIncome,
                expense: summary.monthExpense,
                currency: currency,
              ),
              const SizedBox(height: 16),
              SpendingChart(data: summary.weeklySpending),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FinnCategoryChip(
                        label: 'All',
                        icon: Icons.apps_rounded,
                        selected: _selectedCategory == null,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                      ),
                    ),
                    ...categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FinnCategoryChip(
                          label: category.label,
                          icon: category.icon,
                          selected: _selectedCategory == category,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RecentTransactionsList(
                transactions: visibleTransactions,
                currency: currency,
                onTap: _editTransaction,
              ),
              const SizedBox(height: 16),
              ActiveGoalTeaser(
                goal: summary.activeGoal,
                transactions: summary.recentTransactions,
              ),
            ],
          );
        },
        loading: () => const FinnShimmerList(itemCount: 5),
        error: (error, stackTrace) =>
            const Center(child: Text('Failed to load dashboard')),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void _editTransaction(TransactionEntity transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddEditTransactionSheet(transaction: transaction),
    );
  }
}
