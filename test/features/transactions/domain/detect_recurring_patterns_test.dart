import 'package:flutter_test/flutter_test.dart';
import 'package:finn/features/transactions/domain/entities/transaction_entity.dart';
import 'package:finn/features/transactions/domain/entities/transaction_type.dart';
import 'package:finn/features/transactions/domain/entities/transaction_category.dart';
import 'package:finn/features/transactions/domain/usecases/detect_recurring_patterns.dart';

void main() {
  late DetectRecurringPatterns detectRecurringPatterns;

  setUp(() {
    detectRecurringPatterns = DetectRecurringPatterns();
  });

  group('DetectRecurringPatterns', () {
    test('should detect monthly recurring pattern', () {
      final now = DateTime.now();
      // Month 1: 30 days ago
      // Month 2: 60 days ago
      final month1 = now.subtract(const Duration(days: 30));
      final month2 = now.subtract(const Duration(days: 60));

      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 15.99,
          date: month1,
          type: TransactionType.expense,
          category: TransactionCategory.entertainment,
          createdAt: month1,
          updatedAt: month1,
        ),
        TransactionEntity(
          id: '2',
          amount: 15.99,
          date: month2,
          type: TransactionType.expense,
          category: TransactionCategory.entertainment,
          createdAt: month2,
          updatedAt: month2,
        ),
      ];

      final patterns = detectRecurringPatterns(transactions);

      expect(patterns.length, 1);
      expect(patterns.first.category, TransactionCategory.entertainment);
      expect(patterns.first.estimatedAmount, 15.99);
    });

    test('should not detect pattern for random intervals', () {
      final now = DateTime.now();

      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 50,
          date: now.subtract(const Duration(days: 5)),
          type: TransactionType.expense,
          category: TransactionCategory.food,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: '2',
          amount: 50,
          date: now.subtract(const Duration(days: 20)),
          type: TransactionType.expense,
          category: TransactionCategory.food,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final patterns = detectRecurringPatterns(transactions);
      expect(patterns.isEmpty, true);
    });
  });
}
