import 'package:flutter_test/flutter_test.dart';
import 'package:finn/features/insights/domain/usecases/calculate_health_score.dart';
import 'package:finn/features/insights/domain/entities/health_score.dart';
import 'package:finn/features/transactions/domain/entities/transaction_entity.dart';
import 'package:finn/features/transactions/domain/entities/transaction_type.dart';
import 'package:finn/features/transactions/domain/entities/transaction_category.dart';
import 'package:finn/features/goals/domain/entities/goal_entity.dart';
import 'package:finn/features/goals/domain/entities/goal_type.dart';

void main() {
  late CalculateHealthScore calculateHealthScore;

  setUp(() {
    calculateHealthScore = CalculateHealthScore();
  });

  group('CalculateHealthScore', () {
    test('should return baseline score for empty state', () {
      final score = calculateHealthScore(
        transactions: [],
        goals: [],
        month: '2025_06',
      );

      expect(score.overallScore, 50);
      expect(score.tier, 'Fair');
    });

    test('should calculate high score for good financial habits', () {
      final now = DateTime.now();
      final List<TransactionEntity> transactions = [
        TransactionEntity(
          id: '1',
          amount: 1000,
          date: now,
          type: TransactionType.income,
          category: TransactionCategory.savings,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: '2',
          amount: 2000,
          date: now,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final List<GoalEntity> goals = [
        GoalEntity(
          id: 'g1',
          title: 'Save for car',
          type: GoalType.savings,
          targetAmount: 10000,
          currentAmount: 500,
          icon: '🚗',
          colorHex: '0xFF123456',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final score = calculateHealthScore(
        transactions: transactions,
        goals: goals,
        month: '2025_06',
      );

      expect(score.overallScore, greaterThan(70));
      expect(score.savingsRateScore, greaterThan(0)); 
    });
  });
}
