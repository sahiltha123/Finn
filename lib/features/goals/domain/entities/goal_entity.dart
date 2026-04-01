import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import 'goal_status.dart';
import 'goal_type.dart';

class GoalEntity {
  const GoalEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.icon,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
    this.targetAmount,
    this.currentAmount,
    this.deadline,
    this.category,
    this.streakCount,
    this.streakTarget,
    this.durationDays,
    this.startDate,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final GoalType type;
  final double? targetAmount;
  final double? currentAmount;
  final DateTime? deadline;
  final TransactionCategory? category;
  final int? streakCount;
  final int? streakTarget;
  final int? durationDays;
  final DateTime? startDate;
  final String icon;
  final String colorHex;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalEntity copyWith({
    String? id,
    String? title,
    GoalType? type,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    TransactionCategory? category,
    int? streakCount,
    int? streakTarget,
    int? durationDays,
    DateTime? startDate,
    String? icon,
    String? colorHex,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      streakCount: streakCount ?? this.streakCount,
      streakTarget: streakTarget ?? this.streakTarget,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double progress(List<TransactionEntity> transactions, DateTime now) {
    switch (type) {
      case GoalType.savings:
        final target = targetAmount ?? 0;
        final current = currentAmount ?? 0;
        if (target <= 0) return 0;
        return (current / target).clamp(0, 1);
      case GoalType.budget:
        final limit = targetAmount ?? 0;
        if (limit <= 0 || category == null) return 0;
        final spent = _monthlyCategorySpend(transactions, now);
        return (spent / limit).clamp(0, 1.5);
      case GoalType.noSpend:
        final duration = durationDays ?? 0;
        final start = startDate ?? createdAt;
        if (duration <= 0) return 0;
        final spent = _hasSpentInCategory(transactions, start, now);
        if (spent) {
          final firstIncident = _firstCategoryExpense(transactions, start, now);
          final completedDays = firstIncident == null
              ? 0
              : firstIncident.difference(start).inDays.clamp(0, duration);
          return (completedDays / duration).clamp(0, 1);
        }
        final elapsed = now.difference(start).inDays + 1;
        return (elapsed / duration).clamp(0, 1);
      case GoalType.streak:
        final target = streakTarget ?? 0;
        if (target <= 0) return 0;
        final streak = _currentSavingsStreak(transactions, now);
        return (streak / target).clamp(0, 1);
    }
  }

  GoalStatus status(List<TransactionEntity> transactions, DateTime now) {
    switch (type) {
      case GoalType.savings:
        final value = progress(transactions, now);
        if (value >= 1) return GoalStatus.completed;
        if (deadline != null && now.isAfter(deadline!)) {
          return GoalStatus.failed;
        }
        final expected = _expectedSavingsProgress(now);
        if (value < expected - 0.1) return GoalStatus.atRisk;
        return GoalStatus.onTrack;
      case GoalType.budget:
        final value = progress(transactions, now);
        if (value > 1) return GoalStatus.failed;
        if (value >= 0.8) return GoalStatus.atRisk;
        return GoalStatus.onTrack;
      case GoalType.noSpend:
        final duration = durationDays ?? 0;
        final start = startDate ?? createdAt;
        if (_hasSpentInCategory(transactions, start, now)) {
          return GoalStatus.atRisk;
        }
        if (duration > 0 && now.difference(start).inDays + 1 >= duration) {
          return GoalStatus.completed;
        }
        return GoalStatus.onTrack;
      case GoalType.streak:
        final streak = _currentSavingsStreak(transactions, now);
        final target = streakTarget ?? 0;
        if (target > 0 && streak >= target) return GoalStatus.completed;
        if (streak == 0) return GoalStatus.atRisk;
        return GoalStatus.onTrack;
    }
  }

  double displayValue(List<TransactionEntity> transactions, DateTime now) {
    return switch (type) {
      GoalType.savings => currentAmount ?? 0,
      GoalType.budget => _monthlyCategorySpend(transactions, now),
      GoalType.noSpend => (progress(transactions, now) * (durationDays ?? 0)),
      GoalType.streak => _currentSavingsStreak(transactions, now).toDouble(),
    };
  }

  double displayTarget() {
    return switch (type) {
      GoalType.savings || GoalType.budget => targetAmount ?? 0,
      GoalType.noSpend => (durationDays ?? 0).toDouble(),
      GoalType.streak => (streakTarget ?? 0).toDouble(),
    };
  }

  double _expectedSavingsProgress(DateTime now) {
    if (deadline == null) return 0;
    final totalDays = deadline!.difference(createdAt).inDays;
    if (totalDays <= 0) return 0;
    final elapsed = now.difference(createdAt).inDays.clamp(0, totalDays);
    return elapsed / totalDays;
  }

  double _monthlyCategorySpend(
    List<TransactionEntity> transactions,
    DateTime now,
  ) {
    if (category == null) return 0;
    return transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.category == category &&
              transaction.date.year == now.year &&
              transaction.date.month == now.month,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  bool _hasSpentInCategory(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime now,
  ) {
    if (category == null) return false;
    return transactions.any(
      (transaction) =>
          transaction.type == TransactionType.expense &&
          transaction.category == category &&
          !transaction.date.isBefore(start) &&
          !transaction.date.isAfter(now),
    );
  }

  DateTime? _firstCategoryExpense(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime now,
  ) {
    if (category == null) return null;
    final matches =
        transactions
            .where(
              (transaction) =>
                  transaction.type == TransactionType.expense &&
                  transaction.category == category &&
                  !transaction.date.isBefore(start) &&
                  !transaction.date.isAfter(now),
            )
            .toList()
          ..sort((left, right) => left.date.compareTo(right.date));
    return matches.isEmpty ? null : matches.first.date;
  }

  int _currentSavingsStreak(
    List<TransactionEntity> transactions,
    DateTime now,
  ) {
    final savingsDays =
        transactions
            .where(
              (transaction) =>
                  transaction.category == TransactionCategory.savings &&
                  transaction.type == TransactionType.income,
            )
            .map(
              (item) =>
                  DateTime(item.date.year, item.date.month, item.date.day),
            )
            .toSet()
            .toList()
          ..sort((left, right) => right.compareTo(left));

    var streak = 0;
    var cursor = DateTime(now.year, now.month, now.day);
    while (savingsDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
