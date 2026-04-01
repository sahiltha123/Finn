import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchTransactions({required String uid});

  Future<Either<Failure, Unit>> addTransaction({
    required String uid,
    required TransactionEntity transaction,
  });

  Future<Either<Failure, Unit>> updateTransaction({
    required String uid,
    required TransactionEntity transaction,
  });

  Future<Either<Failure, Unit>> deleteTransaction({
    required String uid,
    required String transactionId,
  });
}
