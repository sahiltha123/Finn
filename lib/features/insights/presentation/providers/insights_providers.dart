import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/user_provider.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/datasources/insights_firestore_datasource.dart';
import '../../data/repositories/insights_repository_impl.dart';
import '../../domain/usecases/generate_finn_tips.dart';
import '../../domain/usecases/watch_monthly_insights.dart';

final insightsMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month, 1),
);

final insightsDatasourceProvider = Provider<InsightsFirestoreDatasource>((ref) {
  return InsightsFirestoreDatasource(ref.watch(transactionRepositoryProvider));
});

final insightsRepositoryProvider = Provider<InsightsRepositoryImpl>((ref) {
  return InsightsRepositoryImpl(ref.watch(insightsDatasourceProvider));
});

final watchMonthlyInsightsUseCaseProvider = Provider<WatchMonthlyInsights>((
  ref,
) {
  return WatchMonthlyInsights(ref.watch(insightsRepositoryProvider));
});

final generateFinnTipsUseCaseProvider = Provider<GenerateFinnTips>(
  (ref) => const GenerateFinnTips(),
);

final insightsProvider = StreamProvider((ref) {
  final user = ref.watch(currentUserProvider);
  final month = ref.watch(insightsMonthProvider);
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(watchMonthlyInsightsUseCaseProvider)(
    uid: user.uid,
    month: month,
  );
});
