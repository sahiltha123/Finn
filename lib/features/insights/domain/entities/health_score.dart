import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

@immutable
class HealthScore extends Equatable {
  const HealthScore({
    required this.overallScore,
    required this.savingsRateScore,
    required this.goalAdherenceScore,
    required this.spendingConsistencyScore,
    required this.budgetDisciplineScore,
    required this.incomeGrowthScore,
    required this.tier,
    required this.primaryInsight,
    required this.lastCalculated,
  });

  /// Scale from 0 to 100
  final int overallScore;
  
  /// Sub-dimension scores (each 0-20)
  final int savingsRateScore;
  final int goalAdherenceScore;
  final int spendingConsistencyScore;
  final int budgetDisciplineScore;
  final int incomeGrowthScore;

  final String tier;
  final String primaryInsight;
  final DateTime lastCalculated;

  static String getTier(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Work';
  }

  @override
  List<Object?> get props => [
        overallScore,
        savingsRateScore,
        goalAdherenceScore,
        spendingConsistencyScore,
        budgetDisciplineScore,
        incomeGrowthScore,
        tier,
        primaryInsight,
      ];
}
