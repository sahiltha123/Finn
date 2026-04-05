import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../transactions/domain/entities/transaction_category.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_status.dart';
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
    super.storedStatus,
    super.previousProgress,
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
      storedStatus: entity.storedStatus,
      previousProgress: entity.previousProgress,
    );
  }

  factory GoalModel.fromMap(Map<String, Object?> map) {
    final deadlineValue = map['deadline'];
    final startDateValue = map['startDate'];
    final createdAtValue = map['createdAt'];
    final updatedAtValue = map['updatedAt'];
    return GoalModel(
      id: map['id']! as String,
      title: map['title']! as String,
      type: GoalType.values.byName(map['type']! as String),
      targetAmount: (map['targetAmount'] as num?)?.toDouble(),
      currentAmount: (map['currentAmount'] as num?)?.toDouble(),
      deadline: deadlineValue == null
          ? null
          : deadlineValue is Timestamp
          ? deadlineValue.toDate()
          : DateTime.parse(deadlineValue as String),
      category: map['category'] == null
          ? null
          : TransactionCategory.values.byName(map['category']! as String),
      streakCount: map['streakCount'] as int?,
      streakTarget: map['streakTarget'] as int?,
      durationDays: map['durationDays'] as int?,
      startDate: startDateValue == null
          ? null
          : startDateValue is Timestamp
          ? startDateValue.toDate()
          : DateTime.parse(startDateValue as String),
      icon: map['icon']! as String,
      colorHex: map['colorHex']! as String,
      isCompleted: map['isCompleted']! as bool,
      storedStatus: GoalStatusX.fromFirestore(map['status'] as String?),
      previousProgress: (map['previousProgress'] as num?)?.toDouble(),
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.parse(createdAtValue! as String),
      updatedAt: updatedAtValue is Timestamp
          ? updatedAtValue.toDate()
          : DateTime.parse(updatedAtValue! as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline == null ? null : Timestamp.fromDate(deadline!),
      'category': category?.name,
      'streakCount': streakCount,
      'streakTarget': streakTarget,
      'durationDays': durationDays,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'icon': icon,
      'colorHex': colorHex,
      'isCompleted': isCompleted,
      'status': (storedStatus ?? GoalStatus.onTrack).firestoreValue,
      'previousProgress': previousProgress,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
