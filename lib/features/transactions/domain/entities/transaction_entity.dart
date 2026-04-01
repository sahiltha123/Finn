import 'transaction_category.dart';
import 'transaction_type.dart';

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.isRecurring = false,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRecurring;

  TransactionEntity copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}
