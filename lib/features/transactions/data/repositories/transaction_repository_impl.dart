import 'package:dartz/dartz.dart';
import 'package:firebase_performance/firebase_performance.dart';

import '../../../../core/utils/analytics_service.dart';
import '../../../../core/utils/goal_automation_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_firestore_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(
    this._datasource,
    this._analyticsService,
    this._goalAutomationService,
  );

  final TransactionFirestoreDatasource _datasource;
  final AnalyticsService _analyticsService;
  final GoalAutomationService _goalAutomationService;

  @override
  Stream<List<TransactionEntity>> watchTransactions({required String uid}) {
    return _datasource.watchTransactions(uid);
  }

  @override
  Future<Either<Failure, Unit>> addTransaction({
    required String uid,
    required TransactionEntity transaction,
  }) async {
    final trace = FirebasePerformance.instance.newTrace('addTransaction');
    await trace.start();
    try {
      await _datasource.addTransaction(uid, transaction);
      await _analyticsService.logTransactionAdded(transaction);
      await _goalAutomationService.evaluateAll(uid);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to save this transaction.'));
    } finally {
      await trace.stop();
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction({
    required String uid,
    required String transactionId,
  }) async {
    final trace = FirebasePerformance.instance.newTrace('deleteTransaction');
    await trace.start();
    try {
      await _datasource.deleteTransaction(uid, transactionId);
      await _goalAutomationService.evaluateAll(uid);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to delete this transaction.'));
    } finally {
      await trace.stop();
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction({
    required String uid,
    required TransactionEntity transaction,
  }) async {
    final trace = FirebasePerformance.instance.newTrace('updateTransaction');
    await trace.start();
    try {
      await _datasource.updateTransaction(uid, transaction);
      await _goalAutomationService.evaluateAll(uid);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to update this transaction.'));
    } finally {
      await trace.stop();
    }
  }
}
