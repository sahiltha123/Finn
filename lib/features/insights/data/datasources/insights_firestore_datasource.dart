import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/repositories/goals_repository.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/insights_entity.dart';
import '../../domain/usecases/calculate_health_score.dart';

class InsightsFirestoreDatasource {
  const InsightsFirestoreDatasource(
    this._transactionRepository,
    this._goalRepository,
    this._firestore,
  );

  final TransactionRepository _transactionRepository;
  final GoalsRepository _goalRepository;
  final FirebaseFirestore _firestore;

  Stream<InsightsEntity> watchMonthlyInsights({
    required String uid,
    required DateTime month,
  }) {
    // Combine transactions and goals streams
    final txnsStream = _transactionRepository.watchTransactions(uid: uid);
    final goalsStream = _goalRepository.watchGoals(uid: uid);

    return _combineStreams(txnsStream, goalsStream).asyncMap((data) async {
      final transactions = data.value1;
      final goals = data.value2;

      final insights = InsightsEntity.fromTransactions(
        transactions: transactions,
        goals: goals,
        month: month,
      );

      final healthScore = CalculateHealthScore()(
        transactions: transactions,
        goals: goals,
        month: _monthKey(month),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('insights_cache')
          .doc(_monthKey(month))
          .set({
            'totalIncome': insights.totalIncome,
            'totalExpense': insights.totalExpense,
            'savingsRate': insights.savingsRate,
            'topCategory': insights.topCategory?.name,
            'weeklyBreakdown': insights.weeklyBreakdown,
            'categoryBreakdown': insights.categoryBreakdown.map(
              (key, value) => MapEntry(key.name, value),
            ),
            'healthScoreManual': {
              'overallScore': healthScore.overallScore,
              'savingsRateScore': healthScore.savingsRateScore,
              'goalAdherenceScore': healthScore.goalAdherenceScore,
              'spendingConsistencyScore': healthScore.spendingConsistencyScore,
              'budgetDisciplineScore': healthScore.budgetDisciplineScore,
              'incomeGrowthScore': healthScore.incomeGrowthScore,
              'tier': healthScore.tier,
              'primaryInsight': healthScore.primaryInsight,
            },
            'generatedAt': Timestamp.fromDate(DateTime.now()),
          }, SetOptions(merge: true));

      return insights;
    });
  }

  Stream<Tuple2<List<TransactionEntity>, List<GoalEntity>>> _combineStreams(
    Stream<List<TransactionEntity>> txns,
    Stream<List<GoalEntity>> goals,
  ) {
    final controller = StreamController<Tuple2<List<TransactionEntity>, List<GoalEntity>>>();
    List<TransactionEntity>? lastTxns;
    List<GoalEntity>? lastGoals;

    void update() {
      if (lastTxns != null && lastGoals != null) {
        controller.add(Tuple2(lastTxns!, lastGoals!));
      }
    }

    final sub1 = txns.listen((t) { lastTxns = t; update(); });
    final sub2 = goals.listen((g) { lastGoals = g; update(); });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }

  String _monthKey(DateTime month) =>
      '${month.year}_${month.month.toString().padLeft(2, '0')}';
}
