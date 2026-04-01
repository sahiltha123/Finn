import '../entities/insights_entity.dart';

abstract class InsightsRepository {
  Stream<InsightsEntity> watchMonthlyInsights({
    required String uid,
    required DateTime month,
  });
}
