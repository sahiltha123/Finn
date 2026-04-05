import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/insights_entity.dart';

class InsightsFirestoreDatasource {
  const InsightsFirestoreDatasource(
    this._transactionRepository,
    this._firestore,
  );

  final TransactionRepository _transactionRepository;
  final FirebaseFirestore _firestore;

  Stream<InsightsEntity> watchMonthlyInsights({
    required String uid,
    required DateTime month,
  }) {
    return _transactionRepository.watchTransactions(uid: uid).asyncMap((
      transactions,
    ) async {
      final insights = InsightsEntity.fromTransactions(
        transactions: transactions,
        month: month,
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
            'generatedAt': Timestamp.fromDate(DateTime.now()),
          }, SetOptions(merge: true));
      return insights;
    });
  }

  String _monthKey(DateTime month) =>
      '${month.year}_${month.month.toString().padLeft(2, '0')}';
}
