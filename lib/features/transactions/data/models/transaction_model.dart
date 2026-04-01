import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.category,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
    super.isRecurring,
  });

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      date: entity.date,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isRecurring: entity.isRecurring,
    );
  }

  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      id: map['id']! as String,
      amount: (map['amount']! as num).toDouble(),
      type: TransactionType.values.byName(map['type']! as String),
      category: TransactionCategory.values.byName(map['category']! as String),
      date: DateTime.parse(map['date']! as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt']! as String),
      updatedAt: DateTime.parse(map['updatedAt']! as String),
      isRecurring: map['isRecurring']! as bool,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRecurring': isRecurring,
    };
  }
}
