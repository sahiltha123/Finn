import '../entities/goal_entity.dart';
import '../repositories/goals_repository.dart';

class WatchGoals {
  const WatchGoals(this._repository);

  final GoalsRepository _repository;

  Stream<List<GoalEntity>> call({required String uid}) {
    return _repository.watchGoals(uid: uid);
  }
}
