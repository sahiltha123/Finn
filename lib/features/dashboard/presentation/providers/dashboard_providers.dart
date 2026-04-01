import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/user_provider.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/datasources/dashboard_firestore_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/usecases/watch_dashboard_summary.dart';

final dashboardDatasourceProvider = Provider<DashboardFirestoreDatasource>((
  ref,
) {
  return DashboardFirestoreDatasource(
    ref.watch(transactionRepositoryProvider),
    ref.watch(goalsRepositoryProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepositoryImpl>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardDatasourceProvider));
});

final watchDashboardSummaryUseCaseProvider = Provider<WatchDashboardSummary>((
  ref,
) {
  return WatchDashboardSummary(ref.watch(dashboardRepositoryProvider));
});

final dashboardSummaryProvider = StreamProvider((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(watchDashboardSummaryUseCaseProvider)(uid: user.uid);
});
