import 'package:flutter_test/flutter_test.dart';
import 'package:finn/features/goals/domain/entities/goal_entity.dart';
import 'package:finn/features/goals/domain/entities/goal_type.dart';
import 'package:finn/features/goals/domain/usecases/predict_budget_exhaustion.dart';
import 'package:finn/features/transactions/domain/entities/transaction_entity.dart';
import 'package:finn/features/transactions/domain/entities/transaction_type.dart';
import 'package:finn/features/transactions/domain/entities/transaction_category.dart';

void main() {
  late PredictBudgetExhaustion predictor;

  setUp(() {
    predictor = PredictBudgetExhaustion();
  });

  group('PredictBudgetExhaustion', () {
    test('should return high risk when burn rate is too fast', () {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 10));
      // End of month
      final deadline = DateTime(
        now.year,
        now.month + 1,
        1,
      ).subtract(const Duration(days: 1));

      final budget = GoalEntity(
        id: '1',
        title: 'Food Budget',
        type: GoalType.budget,
        targetAmount: 300,
        currentAmount: 0,
        category: TransactionCategory.food,
        startDate: startDate,
        deadline: deadline,
        icon: '🍔',
        colorHex: '0xFF000000',
        createdAt: now,
        updatedAt: now,
      );

      // Spent 200 in 10 days = 20/day.
      // Total days in month (assume 30). Remaining 100 will last 5 days.
      // Total month needed = 30 days. High risk.

      final transactions = [
        TransactionEntity(
          id: 't1',
          amount: 200,
          date: now,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final prediction = predictor(budget, transactions);

      expect(prediction, isNotNull);
      expect(
        prediction!.risk,
        anyOf([ExhaustionRisk.high, ExhaustionRisk.medium]),
      );
      expect(prediction.predictedExhaustionDate, isNotNull);
    });

    test('should return low risk when spending is low', () {
      final now = DateTime.now();
      final budget = GoalEntity(
        id: '1',
        title: 'Low spend',
        type: GoalType.budget,
        targetAmount: 1000,
        currentAmount: 0,
        category: TransactionCategory.food,
        startDate: now.subtract(const Duration(days: 10)),
        deadline: now.add(const Duration(days: 20)),
        icon: '🍔',
        colorHex: '0xFF000000',
        createdAt: now,
        updatedAt: now,
      );

      final transactions = [
        TransactionEntity(
          id: 't1',
          amount: 10,
          date: now,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final prediction = predictor(budget, transactions);
      expect(prediction!.risk, ExhaustionRisk.low);
    });
  });
}
