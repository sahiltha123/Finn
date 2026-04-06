import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/datasources/insights_firestore_datasource.dart';
import '../../data/repositories/insights_repository_impl.dart';
import '../../domain/usecases/generate_finn_tips.dart';
import '../../domain/usecases/watch_monthly_insights.dart';
import '../../domain/entities/insights_entity.dart';

import '../../../goals/presentation/providers/goals_providers.dart';
import '../../domain/usecases/calculate_health_score.dart';
import '../../domain/entities/health_score.dart';

final insightsMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month, 1),
);

final insightsDatasourceProvider = Provider<InsightsFirestoreDatasource>((ref) {
  return InsightsFirestoreDatasource(
    ref.watch(transactionRepositoryProvider),
    ref.watch(goalsRepositoryProvider),
    ref.watch(firestoreProvider),
  );
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

final calculateHealthScoreUseCaseProvider = Provider<CalculateHealthScore>(
  (ref) => CalculateHealthScore(),
);

final insightsProvider = StreamProvider<InsightsEntity>((ref) {
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

final healthScoreProvider = Provider<AsyncValue<HealthScore>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final goalsAsync = ref.watch(goalsProvider);
  
  if (transactionsAsync.isLoading || goalsAsync.isLoading) {
    return const AsyncLoading();
  }
  
  final transactions = transactionsAsync.valueOrNull ?? [];
  final goals = goalsAsync.valueOrNull ?? [];
  final now = DateTime.now();
  final monthStr = '${now.year}_${now.month.toString().padLeft(2, '0')}';
  
  try {
    final score = ref.read(calculateHealthScoreUseCaseProvider)(
      transactions: transactions,
      goals: goals,
      month: monthStr,
    );
    return AsyncData(score);
  } catch (e, st) {
    return AsyncError(e, st);
  }
});
