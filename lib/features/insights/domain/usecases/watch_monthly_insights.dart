import '../entities/insights_entity.dart';
import '../repositories/insights_repository.dart';

class WatchMonthlyInsights {
  const WatchMonthlyInsights(this._repository);

  final InsightsRepository _repository;

  Stream<InsightsEntity> call({required String uid, required DateTime month}) {
    return _repository.watchMonthlyInsights(uid: uid, month: month);
  }
}
