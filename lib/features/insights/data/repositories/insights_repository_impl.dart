import '../../domain/entities/insights_entity.dart';
import '../../domain/repositories/insights_repository.dart';
import '../datasources/insights_firestore_datasource.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  const InsightsRepositoryImpl(this._datasource);

  final InsightsFirestoreDatasource _datasource;

  @override
  Stream<InsightsEntity> watchMonthlyInsights({
    required String uid,
    required DateTime month,
  }) {
    return _datasource.watchMonthlyInsights(uid: uid, month: month);
  }
}
