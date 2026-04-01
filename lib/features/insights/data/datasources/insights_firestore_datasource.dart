import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/insights_entity.dart';

class InsightsFirestoreDatasource {
  const InsightsFirestoreDatasource(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Stream<InsightsEntity> watchMonthlyInsights({
    required String uid,
    required DateTime month,
  }) {
    return _transactionRepository
        .watchTransactions(uid: uid)
        .map(
          (transactions) => InsightsEntity.fromTransactions(
            transactions: transactions,
            month: month,
          ),
        );
  }
}
