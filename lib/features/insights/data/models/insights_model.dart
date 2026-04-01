import '../../domain/entities/insights_entity.dart';

class InsightsModel extends InsightsEntity {
  const InsightsModel({
    required super.month,
    required super.totalIncome,
    required super.totalExpense,
    required super.savingsRate,
    required super.topCategory,
    required super.weeklyBreakdown,
    required super.categoryBreakdown,
    required super.sixMonthNet,
    required super.tips,
  });

  factory InsightsModel.fromEntity(InsightsEntity entity) {
    return InsightsModel(
      month: entity.month,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      savingsRate: entity.savingsRate,
      topCategory: entity.topCategory,
      weeklyBreakdown: entity.weeklyBreakdown,
      categoryBreakdown: entity.categoryBreakdown,
      sixMonthNet: entity.sixMonthNet,
      tips: entity.tips,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'month': month.toIso8601String(),
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'savingsRate': savingsRate,
      'topCategory': topCategory?.name,
      'weeklyBreakdown': weeklyBreakdown,
      'categoryBreakdown': categoryBreakdown.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'sixMonthNet': sixMonthNet,
      'tips': tips,
    };
  }
}
