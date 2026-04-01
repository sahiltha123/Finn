import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class WatchDashboardSummary {
  const WatchDashboardSummary(this._repository);

  final DashboardRepository _repository;

  Stream<DashboardSummary> call({required String uid}) {
    return _repository.watchDashboardSummary(uid: uid);
  }
}
