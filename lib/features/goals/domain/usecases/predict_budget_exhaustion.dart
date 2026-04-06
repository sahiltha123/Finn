import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../entities/goal_entity.dart';
import '../entities/goal_type.dart';

enum ExhaustionRisk { low, medium, high, exceeded }

class ExhaustionPrediction {
  const ExhaustionPrediction({
    required this.risk,
    required this.predictedExhaustionDate,
    required this.burnRatePerDay,
    required this.daysRemaining,
  });

  final ExhaustionRisk risk;
  final DateTime? predictedExhaustionDate;
  final double burnRatePerDay;
  final int daysRemaining;
}

class PredictBudgetExhaustion {
  /// Predicts if a [goal] (budget/no-spend) is at risk based on [transactions].
  ExhaustionPrediction? call(
    GoalEntity goal,
    List<TransactionEntity> transactions,
  ) {
    if (goal.type != GoalType.budget && goal.type != GoalType.noSpend) {
      return null;
    }

    final targetAmount = goal.targetAmount;
    if (targetAmount == null || targetAmount <= 0) return null;

    final now = DateTime.now();
    // Default to end of month for simple budget tracking
    final deadline =
        goal.deadline ??
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    final startDate = goal.startDate ?? DateTime(now.year, now.month, 1);

    if (now.isAfter(deadline)) return null;

    // Filter transactions relevant to this budget
    final relevantTransactions = transactions.where((t) {
      if (t.type != TransactionType.expense) return false;
      if (t.date.isBefore(startDate) || t.date.isAfter(now)) return false;
      if (goal.category != null && t.category != goal.category) return false;
      return true;
    }).toList();

    double totalSpent = relevantTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );

    final daysElapsed =
        now.difference(startDate).inDays + 1; // +1 to include today
    final daysRemaining = deadline.difference(now).inDays;

    if (totalSpent >= targetAmount) {
      return ExhaustionPrediction(
        risk: ExhaustionRisk.exceeded,
        predictedExhaustionDate: now,
        burnRatePerDay: totalSpent / daysElapsed,
        daysRemaining: daysRemaining,
      );
    }

    final burnRatePerDay = totalSpent / daysElapsed;
    if (burnRatePerDay <= 0) {
      return ExhaustionPrediction(
        risk: ExhaustionRisk.low,
        predictedExhaustionDate: null,
        burnRatePerDay: 0,
        daysRemaining: daysRemaining,
      );
    }

    final daysUntilExhaustion = (targetAmount - totalSpent) / burnRatePerDay;
    final predictedDate = now.add(Duration(days: daysUntilExhaustion.floor()));

    ExhaustionRisk risk;
    if (predictedDate.isBefore(deadline)) {
      final difference = deadline.difference(predictedDate).inDays;
      if (difference > 5) {
        risk = ExhaustionRisk.high;
      } else {
        risk = ExhaustionRisk.medium;
      }
    } else {
      risk = ExhaustionRisk.low;
    }

    return ExhaustionPrediction(
      risk: risk,
      predictedExhaustionDate: predictedDate,
      burnRatePerDay: burnRatePerDay,
      daysRemaining: daysRemaining,
    );
  }
}
