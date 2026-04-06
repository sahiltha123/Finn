import 'dart:math';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/entities/goal_status.dart';
import '../../../goals/domain/entities/goal_type.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../entities/health_score.dart';

class CalculateHealthScore {
  HealthScore call({
    required List<TransactionEntity> transactions,
    required List<GoalEntity> goals,
    required String month, // 'yyyy_MM' format
  }) {
    if (transactions.isEmpty) {
      return HealthScore(
        overallScore: 50,
        savingsRateScore: 10,
        goalAdherenceScore: 10,
        spendingConsistencyScore: 10,
        budgetDisciplineScore: 10,
        incomeGrowthScore: 10,
        tier: 'Fair',
        primaryInsight: 'Log some transactions to see your real score.',
        lastCalculated: DateTime.now(),
      );
    }

    // 1. SAVINGS RATE SCORE (0–20)
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final savingsRate = income > 0 ? (income - expenses) / income : 0.0;
    final savingsScore = (min(1.0, max(0, savingsRate) / 0.20) * 20).round();

    // 2. GOAL ADHERENCE SCORE (0–20)
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    int goalScore = 15; // default if no goals
    if (activeGoals.isNotEmpty) {
      final onTrack = activeGoals
          .where((g) => g.status(transactions, DateTime.now()) == GoalStatus.onTrack)
          .length;
      goalScore = ((onTrack / activeGoals.length) * 20).round();
    }

    // 3. SPENDING CONSISTENCY SCORE (0–20)
    final weeklyTotals = _getWeeklyExpenseTotals(transactions);
    final consistencyScore = _calculateConsistencyScore(weeklyTotals);

    // 4. BUDGET DISCIPLINE SCORE (0–20)
    final budgetGoals = goals.where((g) => g.type == GoalType.budget).toList();
    int budgetScore = 15; // default if no budgets
    if (budgetGoals.isNotEmpty) {
      final notExceeded = budgetGoals
          .where((g) => g.status(transactions, DateTime.now()) != GoalStatus.failed)
          .length;
      budgetScore = ((notExceeded / budgetGoals.length) * 20).round();
    }

    // 5. INCOME GROWTH SCORE (0–20) - Simple implementation: 10 by default
    const growthScore = 10;

    final total = savingsScore + goalScore + consistencyScore + budgetScore + growthScore;
    final tier = HealthScore.getTier(total);

    return HealthScore(
      overallScore: total.clamp(0, 100),
      savingsRateScore: savingsScore,
      goalAdherenceScore: goalScore,
      spendingConsistencyScore: consistencyScore,
      budgetDisciplineScore: budgetScore,
      incomeGrowthScore: growthScore,
      tier: tier,
      primaryInsight: _generateInsight(total, savingsScore, goalScore),
      lastCalculated: DateTime.now(),
    );
  }

  Map<int, double> _getWeeklyExpenseTotals(List<TransactionEntity> transactions) {
    final totals = <int, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        final week = ((t.date.day - 1) ~/ 7) + 1;
        totals[week] = (totals[week] ?? 0.0) + t.amount;
      }
    }
    return totals;
  }

  int _calculateConsistencyScore(Map<int, double> weeklyTotals) {
    if (weeklyTotals.isEmpty) return 10;
    if (weeklyTotals.length == 1) return 15;

    final values = weeklyTotals.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    if (mean == 0) return 20;

    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final stdDev = sqrt(variance);
    final cv = stdDev / mean;

    // Lower CV = more consistency.
    // Normalized score: 20 points if CV=0, 0 points if CV>=1.
    return (max(0.0, 1.0 - cv) * 20).round().clamp(0, 20);
  }

  String _generateInsight(int total, int savingsScore, int goalScore) {
    if (savingsScore < 10) return 'Your savings rate is low. Try the 50/30/20 rule.';
    if (goalScore < 12) return 'Some of your goals are at risk. Check your "Goals" tab for details.';
    if (total >= 85) return 'Incredible! You have strong control over your finances.';
    return 'Good momentum. Stay consistent to reach "Excellent" status.';
  }
}
