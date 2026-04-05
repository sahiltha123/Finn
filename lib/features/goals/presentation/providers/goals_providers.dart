import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/providers/service_providers.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../data/datasources/goals_firestore_datasource.dart';
import '../../data/repositories/goals_repository_impl.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/update_goal_progress.dart';
import '../../domain/usecases/watch_goals.dart';

final goalsDatasourceProvider = Provider<GoalsFirestoreDatasource>((ref) {
  return GoalsFirestoreDatasource(ref.watch(firestoreProvider));
});

final goalsRepositoryProvider = Provider<GoalsRepositoryImpl>((ref) {
  return GoalsRepositoryImpl(
    ref.watch(goalsDatasourceProvider),
    ref.watch(analyticsServiceProvider),
    ref.watch(goalAutomationServiceProvider),
  );
});

final watchGoalsUseCaseProvider = Provider<WatchGoals>((ref) {
  return WatchGoals(ref.watch(goalsRepositoryProvider));
});

final createGoalUseCaseProvider = Provider<CreateGoal>((ref) {
  return CreateGoal(ref.watch(goalsRepositoryProvider));
});

final updateGoalProgressUseCaseProvider = Provider<UpdateGoalProgress>((ref) {
  return UpdateGoalProgress(ref.watch(goalsRepositoryProvider));
});

final deleteGoalUseCaseProvider = Provider<DeleteGoal>((ref) {
  return DeleteGoal(ref.watch(goalsRepositoryProvider));
});

final goalsProvider = StreamProvider((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(watchGoalsUseCaseProvider)(uid: user.uid);
});
