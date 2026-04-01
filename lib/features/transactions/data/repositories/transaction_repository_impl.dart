import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_firestore_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._datasource);

  final TransactionFirestoreDatasource _datasource;

  @override
  Stream<List<TransactionEntity>> watchTransactions({required String uid}) {
    return _datasource.watchTransactions(uid);
  }

  @override
  Future<Either<Failure, Unit>> addTransaction({
    required String uid,
    required TransactionEntity transaction,
  }) async {
    try {
      await _datasource.addTransaction(uid, transaction);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to save this transaction.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction({
    required String uid,
    required String transactionId,
  }) async {
    try {
      await _datasource.deleteTransaction(uid, transactionId);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to delete this transaction.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction({
    required String uid,
    required TransactionEntity transaction,
  }) async {
    try {
      await _datasource.updateTransaction(uid, transaction);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to update this transaction.'));
    }
  }
}
