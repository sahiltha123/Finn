import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String uid,
    required TransactionEntity transaction,
  }) {
    return _repository.updateTransaction(uid: uid, transaction: transaction);
  }
}
