import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_type.dart';
import '../models/goal_model.dart';

class GoalsFirestoreDatasource {
  GoalsFirestoreDatasource(this._preferences);

  final SharedPreferences _preferences;
  final Map<String, StreamController<List<GoalModel>>> _controllers =
      <String, StreamController<List<GoalModel>>>{};

  Stream<List<GoalModel>> watchGoals(String uid) {
    final controller = _controllers.putIfAbsent(
      uid,
      () => StreamController<List<GoalModel>>.broadcast(),
    );
    controller.add(_read(uid));
    return controller.stream;
  }

  Future<void> createGoal(String uid, GoalEntity goal) async {
    final goals = _read(uid);
    goals.add(GoalModel.fromEntity(goal));
    await _save(uid, goals);
  }

  Future<void> updateGoal(String uid, GoalEntity goal) async {
    final goals = _read(uid);
    final index = goals.indexWhere((item) => item.id == goal.id);
    if (index == -1) throw const StorageException('Goal not found.');
    goals[index] = GoalModel.fromEntity(goal);
    await _save(uid, goals);
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    final goals = _read(uid);
    goals.removeWhere((item) => item.id == goalId);
    await _save(uid, goals);
  }

  List<GoalModel> _read(String uid) {
    final raw = _preferences.getString(_storageKey(uid));
    if (raw == null) {
      final seeded = _seedGoals();
      _preferences.setString(
        _storageKey(uid),
        jsonEncode(seeded.map((item) => item.toMap()).toList()),
      );
      return seeded;
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => GoalModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(String uid, List<GoalModel> goals) async {
    await _preferences.setString(
      _storageKey(uid),
      jsonEncode(goals.map((item) => item.toMap()).toList()),
    );
    _controllers[uid]?.add(goals);
  }

  String _storageKey(String uid) => 'finn_goals_$uid';

  List<GoalModel> _seedGoals() {
    final now = DateTime.now();
    return [
      GoalModel(
        id: 'goal_savings_trip',
        title: 'Goa weekend fund',
        type: GoalType.savings,
        targetAmount: 18000,
        currentAmount: 9000,
        deadline: now.add(const Duration(days: 40)),
        icon: '🏖',
        colorHex: '0xFF1A73E8',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now,
      ),
      GoalModel(
        id: 'goal_budget_food',
        title: 'Food budget',
        type: GoalType.budget,
        targetAmount: 5000,
        category: TransactionCategory.food,
        icon: '🍜',
        colorHex: '0xFFFF6B6B',
        createdAt: DateTime(now.year, now.month, 1),
        updatedAt: now,
      ),
      GoalModel(
        id: 'goal_nospend_shop',
        title: 'No shopping sprint',
        type: GoalType.noSpend,
        category: TransactionCategory.shopping,
        durationDays: 10,
        startDate: now.subtract(const Duration(days: 3)),
        icon: '🛍',
        colorHex: '0xFFFFBE0B',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      GoalModel(
        id: 'goal_streak_save',
        title: 'Savings streak',
        type: GoalType.streak,
        streakTarget: 7,
        icon: '🔥',
        colorHex: '0xFF2A9D8F',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now,
      ),
    ];
  }
}
