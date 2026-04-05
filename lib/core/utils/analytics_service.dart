import 'package:firebase_analytics/firebase_analytics.dart';

import '../../features/goals/domain/entities/goal_entity.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';

class AnalyticsService {
  const AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> logTransactionAdded(TransactionEntity transaction) {
    return _analytics.logEvent(
      name: 'transaction_added',
      parameters: {
        'type': transaction.type.name,
        'category': transaction.category.name,
        'amount_range': _amountRange(transaction.amount),
      },
    );
  }

  Future<void> logGoalCreated(GoalEntity goal) {
    return _analytics.logEvent(
      name: 'goal_created',
      parameters: {'goal_type': goal.type.name},
    );
  }

  Future<void> logGoalCompleted(GoalEntity goal) {
    return _analytics.logEvent(
      name: 'goal_completed',
      parameters: {'goal_type': goal.type.name},
    );
  }

  Future<void> logGoalMilestone50(GoalEntity goal) {
    return _analytics.logEvent(
      name: 'goal_milestone_50',
      parameters: {'goal_id': goal.id},
    );
  }

  Future<void> logInsightsViewed(String monthString) {
    return _analytics.logEvent(
      name: 'insights_viewed',
      parameters: {'month': monthString},
    );
  }

  String _amountRange(double amount) {
    if (amount < 500) return '0_499';
    if (amount < 2000) return '500_1999';
    if (amount < 10000) return '2000_9999';
    return '10000_plus';
  }
}
