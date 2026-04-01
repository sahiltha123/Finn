import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/goal_entity.dart';
import '../repositories/goals_repository.dart';

class CreateGoal {
  const CreateGoal(this._repository);

  final GoalsRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String uid,
    required GoalEntity goal,
  }) {
    return _repository.createGoal(uid: uid, goal: goal);
  }
}
