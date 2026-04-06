import '../../../goals/domain/entities/goal_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/domain/entities/recurring_pattern.dart';
import '../../../transactions/domain/usecases/detect_recurring_patterns.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.weeklySpending,
    required this.recentTransactions,
    required this.activeGoal,
    required this.recurringPatterns,
  });

  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  final Map<String, double> weeklySpending;
  final List<TransactionEntity> recentTransactions;
  final GoalEntity? activeGoal;
  final List<RecurringPattern> recurringPatterns;

  factory DashboardSummary.fromData({
    required List<TransactionEntity> transactions,
    required List<GoalEntity> goals,
    required DateTime now,
  }) {
    final monthTransactions = transactions
        .where(
          (transaction) =>
              transaction.date.year == now.year &&
              transaction.date.month == now.month,
        )
        .toList();
    final monthIncome = monthTransactions
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final monthExpense = monthTransactions
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final totalBalance = transactions.fold<double>(
      0,
      (sum, item) => item.type == TransactionType.income
          ? sum + item.amount
          : sum - item.amount,
    );

    final weekly = <String, double>{};
    const labels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var index = 0; index < labels.length; index++) {
      weekly[labels[index]] = 0;
    }
    for (final transaction in transactions.where(
      (item) =>
          item.type == TransactionType.expense &&
          now.difference(item.date).inDays >= 0 &&
          now.difference(item.date).inDays < 7,
    )) {
      final label = labels[(transaction.date.weekday - 1).clamp(0, 6)];
      weekly[label] = (weekly[label] ?? 0) + transaction.amount;
    }

    GoalEntity? activeGoal;
    if (goals.isNotEmpty) {
      final sorted = goals.toList()
        ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
      activeGoal = sorted.first;
    }

    final detectPatterns = DetectRecurringPatterns();
    final recurringPatterns = detectPatterns.call(transactions);

    return DashboardSummary(
      totalBalance: totalBalance,
      monthIncome: monthIncome,
      monthExpense: monthExpense,
      weeklySpending: weekly,
      recentTransactions: transactions.take(5).toList(),
      activeGoal: activeGoal,
      recurringPatterns: recurringPatterns,
    );
  }
}
