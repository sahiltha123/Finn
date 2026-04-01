import '../../../transactions/domain/entities/transaction_category.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_type.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.title,
    required super.type,
    required super.icon,
    required super.colorHex,
    required super.createdAt,
    required super.updatedAt,
    super.targetAmount,
    super.currentAmount,
    super.deadline,
    super.category,
    super.streakCount,
    super.streakTarget,
    super.durationDays,
    super.startDate,
    super.isCompleted,
  });

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      title: entity.title,
      type: entity.type,
      icon: entity.icon,
      colorHex: entity.colorHex,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadline: entity.deadline,
      category: entity.category,
      streakCount: entity.streakCount,
      streakTarget: entity.streakTarget,
      durationDays: entity.durationDays,
      startDate: entity.startDate,
      isCompleted: entity.isCompleted,
    );
  }

  factory GoalModel.fromMap(Map<String, Object?> map) {
    return GoalModel(
      id: map['id']! as String,
      title: map['title']! as String,
      type: GoalType.values.byName(map['type']! as String),
      targetAmount: (map['targetAmount'] as num?)?.toDouble(),
      currentAmount: (map['currentAmount'] as num?)?.toDouble(),
      deadline: map['deadline'] == null
          ? null
          : DateTime.parse(map['deadline']! as String),
      category: map['category'] == null
          ? null
          : TransactionCategory.values.byName(map['category']! as String),
      streakCount: map['streakCount'] as int?,
      streakTarget: map['streakTarget'] as int?,
      durationDays: map['durationDays'] as int?,
      startDate: map['startDate'] == null
          ? null
          : DateTime.parse(map['startDate']! as String),
      icon: map['icon']! as String,
      colorHex: map['colorHex']! as String,
      isCompleted: map['isCompleted']! as bool,
      createdAt: DateTime.parse(map['createdAt']! as String),
      updatedAt: DateTime.parse(map['updatedAt']! as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'category': category?.name,
      'streakCount': streakCount,
      'streakTarget': streakTarget,
      'durationDays': durationDays,
      'startDate': startDate?.toIso8601String(),
      'icon': icon,
      'colorHex': colorHex,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
