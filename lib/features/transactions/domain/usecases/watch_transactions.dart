import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class WatchTransactions {
  const WatchTransactions(this._repository);

  final TransactionRepository _repository;

  Stream<List<TransactionEntity>> call({required String uid}) {
    return _repository.watchTransactions(uid: uid);
  }
}
