import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_firestore_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._datasource);

  final DashboardFirestoreDatasource _datasource;

  @override
  Stream<DashboardSummary> watchDashboardSummary({required String uid}) {
    return _datasource.watchDashboardSummary(uid);
  }
}
