import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/goal_entity.dart';

abstract class GoalsRepository {
  Stream<List<GoalEntity>> watchGoals({required String uid});

  Future<Either<Failure, Unit>> createGoal({
    required String uid,
    required GoalEntity goal,
  });

  Future<Either<Failure, Unit>> updateGoal({
    required String uid,
    required GoalEntity goal,
  });

  Future<Either<Failure, Unit>> deleteGoal({
    required String uid,
    required String goalId,
  });
}
