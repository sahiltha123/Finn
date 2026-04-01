import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String uid,
    required String transactionId,
  }) {
    return _repository.deleteTransaction(
      uid: uid,
      transactionId: transactionId,
    );
  }
}
