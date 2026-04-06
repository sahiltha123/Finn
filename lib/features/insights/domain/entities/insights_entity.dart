import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/entities/goal_type.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../goals/domain/usecases/predict_budget_exhaustion.dart';

class InsightsEntity {
  const InsightsEntity({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.savingsRate,
    required this.topCategory,
    required this.weeklyBreakdown,
    required this.categoryBreakdown,
    required this.sixMonthNet,
    required this.tips,
  });

  final DateTime month;
  final double totalIncome;
  final double totalExpense;
  final double savingsRate;
  final TransactionCategory? topCategory;
  final Map<String, double> weeklyBreakdown;
  final Map<TransactionCategory, double> categoryBreakdown;
  final List<double> sixMonthNet;
  final List<String> tips;

  factory InsightsEntity.fromTransactions({
    required List<TransactionEntity> transactions,
    required List<GoalEntity> goals,
    required DateTime month,
  }) {
    final monthTransactions = transactions
        .where(
          (transaction) =>
              transaction.date.year == month.year &&
              transaction.date.month == month.month,
        )
        .toList();

    final income = monthTransactions
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expense = monthTransactions
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final savingsRate = income <= 0
        ? 0.0
        : ((income - expense) / income).clamp(0.0, 1.0);

    final categoryBreakdown = <TransactionCategory, double>{};
    for (final transaction in monthTransactions.where(
      (item) => item.type == TransactionType.expense,
    )) {
      categoryBreakdown[transaction.category] =
          (categoryBreakdown[transaction.category] ?? 0) + transaction.amount;
    }

    TransactionCategory? topCategory;
    if (categoryBreakdown.isNotEmpty) {
      final sorted = categoryBreakdown.entries.toList()
        ..sort((left, right) => right.value.compareTo(left.value));
      topCategory = sorted.first.key;
    }

    final weeklyBreakdown = <String, double>{
      'W1': 0,
      'W2': 0,
      'W3': 0,
      'W4': 0,
    };
    for (final transaction in monthTransactions.where(
      (item) => item.type == TransactionType.expense,
    )) {
      final week = ((transaction.date.day - 1) ~/ 7) + 1;
      final key = 'W${week.clamp(1, 4)}';
      weeklyBreakdown[key] = (weeklyBreakdown[key] ?? 0) + transaction.amount;
    }

    final sixMonthNet = List<double>.generate(6, (index) {
      final target = DateTime(month.year, month.month - (5 - index), 1);
      final targetTransactions = transactions.where(
        (transaction) =>
            transaction.date.year == target.year &&
            transaction.date.month == target.month,
      );
      return targetTransactions.fold<double>(
        0,
        (sum, item) => item.type == TransactionType.income
            ? sum + item.amount
            : sum - item.amount,
      );
    });

    final tips = _buildTips(
      totalIncome: income,
      totalExpense: expense,
      topCategory: topCategory,
      savingsRate: savingsRate,
      goals: goals,
      monthTransactions: monthTransactions,
    );

    return InsightsEntity(
      month: month,
      totalIncome: income,
      totalExpense: expense,
      savingsRate: savingsRate,
      topCategory: topCategory,
      weeklyBreakdown: weeklyBreakdown,
      categoryBreakdown: categoryBreakdown,
      sixMonthNet: sixMonthNet,
      tips: tips,
    );
  }

  static List<String> _buildTips({
    required double totalIncome,
    required double totalExpense,
    required TransactionCategory? topCategory,
    required double savingsRate,
    required List<GoalEntity> goals,
    required List<TransactionEntity> monthTransactions,
  }) {
    final tips = [
      if (topCategory != null)
        'Your biggest spend category this month is ${topCategory.label.toLowerCase()}.',
      if (savingsRate >= 0.25)
        'Nice work. You are saving more than 25% of your income this month.'
      else
        'A small recurring transfer could help lift your savings rate this month.',
      if (totalExpense > totalIncome && totalIncome > 0)
        'Expenses are currently outpacing income, so this is a good week to trim one category.'
      else if (totalIncome > 0)
        'You are still in the green this month. Keep the momentum going.',
    ];

    // Add predictive tips
    final predictor = PredictBudgetExhaustion();
    final budgetGoals = goals.where((g) => g.type == GoalType.budget).toList();
    for (final budget in budgetGoals) {
      final prediction = predictor(budget, monthTransactions);
      if (prediction != null &&
          (prediction.risk == ExhaustionRisk.high ||
              prediction.risk == ExhaustionRisk.exceeded) &&
          prediction.predictedExhaustionDate != null) {
        final dateStr =
            '${prediction.predictedExhaustionDate!.day}/${prediction.predictedExhaustionDate!.month}';
        tips.add(
          "You're spending ₹${prediction.burnRatePerDay.toStringAsFixed(0)}/day on ${budget.title}. Your budget might run out by $dateStr.",
        );
      }
    }

    return tips;
  }
}
