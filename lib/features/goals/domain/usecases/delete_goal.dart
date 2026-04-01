import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/goals_repository.dart';

class DeleteGoal {
  const DeleteGoal(this._repository);

  final GoalsRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String uid,
    required String goalId,
  }) {
    return _repository.deleteGoal(uid: uid, goalId: goalId);
  }
}
