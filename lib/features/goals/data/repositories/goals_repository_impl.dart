import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_firestore_datasource.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  const GoalsRepositoryImpl(this._datasource);

  final GoalsFirestoreDatasource _datasource;

  @override
  Stream<List<GoalEntity>> watchGoals({required String uid}) {
    return _datasource.watchGoals(uid);
  }

  @override
  Future<Either<Failure, Unit>> createGoal({
    required String uid,
    required GoalEntity goal,
  }) async {
    try {
      await _datasource.createGoal(uid, goal);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to create this challenge.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGoal({
    required String uid,
    required String goalId,
  }) async {
    try {
      await _datasource.deleteGoal(uid, goalId);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to delete this challenge.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateGoal({
    required String uid,
    required GoalEntity goal,
  }) async {
    try {
      await _datasource.updateGoal(uid, goal);
      return right(unit);
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to update this challenge.'));
    }
  }
}
