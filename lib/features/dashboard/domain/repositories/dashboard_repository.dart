import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Stream<DashboardSummary> watchDashboardSummary({required String uid});
}
