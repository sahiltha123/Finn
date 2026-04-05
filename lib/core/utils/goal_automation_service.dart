import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/goals/data/models/goal_model.dart';
import '../../features/goals/domain/entities/goal_status.dart';
import '../../features/goals/domain/entities/goal_type.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import 'analytics_service.dart';
import 'local_notification_service.dart';

class GoalAutomationService {
  const GoalAutomationService({
    required FirebaseFirestore firestore,
    required AnalyticsService analyticsService,
    required LocalNotificationService notificationService,
  }) : _firestore = firestore,
       _analyticsService = analyticsService,
       _notificationService = notificationService;

  final FirebaseFirestore _firestore;
  final AnalyticsService _analyticsService;
  final LocalNotificationService _notificationService;

  Future<void> evaluateAll(String uid) async {
    final goalsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .get();
    final transactionsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    final transactions = transactionsSnapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
    final now = DateTime.now();

    for (final goalDoc in goalsSnapshot.docs) {
      final goal = GoalModel.fromMap(goalDoc.data());
      final previousProgress = goal.previousProgress ?? 0;
      final progress = goal.progress(transactions, now);
      final status = goal.status(transactions, now);
      final currentAmount = goal.displayValue(transactions, now);
      final streakCount = goal.type == GoalType.streak
          ? currentAmount.round()
          : goal.streakCount;

      final updates = <String, Object?>{
        'status': status.firestoreValue,
        'isCompleted': status == GoalStatus.completed,
        'previousProgress': progress,
        'updatedAt': Timestamp.fromDate(now),
      };

      if (goal.type == GoalType.budget || goal.type == GoalType.savings) {
        updates['currentAmount'] = currentAmount;
      }
      if (goal.type == GoalType.streak && streakCount != null) {
        updates['streakCount'] = streakCount;
      }

      await goalDoc.reference.set(updates, SetOptions(merge: true));

      if (previousProgress < 0.5 && progress >= 0.5) {
        await _analyticsService.logGoalMilestone50(goal);
        await _notificationService.showGoalHalfway(goal.title);
      }

      if (goal.isCompleted == false && status == GoalStatus.completed) {
        await _analyticsService.logGoalCompleted(goal);
        await _notificationService.showGoalCompleted(goal.title);
      }

      if (goal.type == GoalType.budget &&
          previousProgress < 0.8 &&
          progress >= 0.8) {
        await _notificationService.showBudgetAlert(goal.title);
      }

      if (goal.type == GoalType.streak &&
          status == GoalStatus.atRisk &&
          progress == 0) {
        await _notificationService.showStreakRisk();
      }
    }
  }
}
