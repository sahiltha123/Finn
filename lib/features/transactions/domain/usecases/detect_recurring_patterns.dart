import '../entities/recurring_pattern.dart';
import '../entities/transaction_category.dart';
import '../entities/transaction_entity.dart';
import '../entities/transaction_type.dart';

class DetectRecurringPatterns {
  /// Scans [transactions] looking for charges that happen roughly every 30 days
  /// with roughly the same amount.
  List<RecurringPattern> call(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return [];

    final expenseTransactions =
        transactions.where((t) => t.type == TransactionType.expense).toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // descending by date

    final patterns = <RecurringPattern>[];

    // Group by category to find patterns
    final groupedByCategory = <String, List<TransactionEntity>>{};
    for (final t in expenseTransactions) {
      groupedByCategory.putIfAbsent(t.category.name, () => []).add(t);
    }

    // Heuristics for detection:
    // 1. Same category
    // 2. Similar amount (± 15%)
    // 3. Roughly 30 days apart (27-33 days) or 7 days apart (6-8 days)
    // 4. Must have at least 2 occurrences

    for (final entry in groupedByCategory.entries) {
      final items = entry.value;
      if (items.length < 2) continue;

      // We look for consecutive items that match the spacing.
      for (var i = 0; i < items.length - 1; i++) {
        final recent = items[i];
        final previous = items[i + 1];

        final daysBetween = recent.date.difference(previous.date).inDays;

        // Check if it's a monthly pattern (~30 days) or weekly (~7 days)
        final isMonthly = daysBetween >= 27 && daysBetween <= 33;
        final isWeekly = daysBetween >= 6 && daysBetween <= 8;

        if (isMonthly || isWeekly) {
          // Check if amount is roughly similar (± 15%)
          final diffRatio =
              (recent.amount - previous.amount).abs() / previous.amount;
          if (diffRatio <= 0.15) {
            // High confidence pattern detected
            final interval = isMonthly ? 30 : 7;
            final nextExpectedDate = recent.date.add(Duration(days: interval));

            // Only add if next expected date is in the future
            if (nextExpectedDate.isAfter(DateTime.now())) {
              patterns.add(
                RecurringPattern(
                  id: 'pattern_${recent.id}',
                  category: recent.category,
                  title: recent.notes != null && recent.notes!.isNotEmpty
                      ? recent.notes!
                      : '${isMonthly ? "Monthly" : "Weekly"} ${recent.category.label}',
                  estimatedAmount: recent.amount,
                  predictedNextDate: nextExpectedDate,
                  confidenceScore: 0.85,
                ),
              );
              break; // One pattern per category is enough for this simple heuristic
            }
          }
        }
      }
    }

    return patterns;
  }
}
