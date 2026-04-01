import 'dart:async';

import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/repositories/goals_repository.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardFirestoreDatasource {
  const DashboardFirestoreDatasource(
    this._transactionRepository,
    this._goalsRepository,
  );

  final TransactionRepository _transactionRepository;
  final GoalsRepository _goalsRepository;

  Stream<DashboardSummary> watchDashboardSummary(String uid) {
    late StreamController<DashboardSummary> controller;
    StreamSubscription<List<TransactionEntity>>? transactionSubscription;
    StreamSubscription<List<GoalEntity>>? goalSubscription;
    var transactions = <TransactionEntity>[];
    var goals = <GoalEntity>[];

    void emit() {
      controller.add(
        DashboardSummary.fromData(
          transactions: transactions,
          goals: goals,
          now: DateTime.now(),
        ),
      );
    }

    controller = StreamController<DashboardSummary>.broadcast(
      onListen: () {
        transactionSubscription = _transactionRepository
            .watchTransactions(uid: uid)
            .listen((value) {
              transactions = value;
              emit();
            });
        goalSubscription = _goalsRepository.watchGoals(uid: uid).listen((
          value,
        ) {
          goals = value;
          emit();
        });
      },
      onCancel: () async {
        await transactionSubscription?.cancel();
        await goalSubscription?.cancel();
      },
    );

    return controller.stream;
  }
}
