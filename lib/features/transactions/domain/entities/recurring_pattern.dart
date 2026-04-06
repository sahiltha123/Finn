import 'package:flutter/foundation.dart';
import 'transaction_category.dart';

@immutable
class RecurringPattern {
  const RecurringPattern({
    required this.id,
    required this.category,
    required this.title,
    required this.estimatedAmount,
    required this.predictedNextDate,
    required this.confidenceScore,
  });

  final String id;
  final TransactionCategory category;
  final String title;
  final double estimatedAmount;
  final DateTime predictedNextDate;
  final double confidenceScore;

  RecurringPattern copyWith({
    String? id,
    TransactionCategory? category,
    String? title,
    double? estimatedAmount,
    DateTime? predictedNextDate,
    double? confidenceScore,
  }) {
    return RecurringPattern(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      predictedNextDate: predictedNextDate ?? this.predictedNextDate,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringPattern &&
        other.id == id &&
        other.category == category &&
        other.title == title &&
        other.estimatedAmount == estimatedAmount &&
        other.predictedNextDate == predictedNextDate &&
        other.confidenceScore == confidenceScore;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        category.hashCode ^
        title.hashCode ^
        estimatedAmount.hashCode ^
        predictedNextDate.hashCode ^
        confidenceScore.hashCode;
  }
}
