import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/finn_category_chip.dart';
import '../../../../shared/widgets/finn_error_widget.dart';
import '../../../../shared/widgets/finn_shimmer_list.dart';
import '../../../../shared/widgets/finn_snackbar.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/entities/goal_type.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../goals/presentation/widgets/create_goal_sheet.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/widgets/add_edit_transaction_sheet.dart';
import '../../presentation/providers/dashboard_providers.dart';
import '../widgets/active_goal_teaser.dart';
import '../widgets/balance_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/spending_chart.dart';
import '../widgets/summary_row.dart';
import '../widgets/recurring_pattern_teaser.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  TransactionCategory? _selectedCategory;
  final Set<String> _dismissedPatterns = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingGoal();
    });
  }

  void _checkPendingGoal() {
    final session = ref.read(appSessionProvider);
    if (session.pendingInitialGoal && session.monthlyIncome != null) {
      session.setPendingInitialGoal(false);
      final suggestedSavingsAmount = session.monthlyIncome! * 0.20;
      final now = DateTime.now();
      final suggestedGoal = GoalEntity(
        id: 'goal_${now.microsecondsSinceEpoch}',
        title: 'Monthly Savings Goal',
        type: GoalType.savings,
        targetAmount: suggestedSavingsAmount,
        currentAmount: 0,
        deadline: DateTime(now.year, now.month + 1, 1),
        icon: '💰',
        colorHex: '0xFF34A853',
        createdAt: now,
        updatedAt: now,
      );

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => CreateGoalSheet(
          initialGoal: suggestedGoal,
          onCreate: (goal) async {
            final user = ref.read(currentUserProvider);
            if (user == null) return;
            final result = await ref.read(createGoalUseCaseProvider)(
              uid: user.uid,
              goal: goal,
            );
            if (!context.mounted) return;
            result.fold(
              (failure) => showFinnSnackBar(context, message: failure.message),
              (_) async {
                await HapticFeedback.lightImpact();
                if (!context.mounted) return;
                showFinnSnackBar(context, message: 'Challenge created');
              },
            );
          },
        ),
      );
    }
  }

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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
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
              if (summary.recurringPatterns.isNotEmpty && !_dismissedPatterns.contains(summary.recurringPatterns.first.id)) ...[
                const SizedBox(height: 16),
                RecurringPatternTeaser(
                  patterns: summary.recurringPatterns,
                  currency: currency,
                  onDismiss: (pattern) => setState(() => _dismissedPatterns.add(pattern.id)),
                ),
              ],
            ],
          );
        },
        loading: () => const FinnShimmerList(itemCount: 5),
        error: (error, stackTrace) => FinnErrorWidget(
          message: 'Failed to load your dashboard.',
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
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
      useRootNavigator: true,
      builder: (context) => AddEditTransactionSheet(transaction: transaction),
    );
  }
}
