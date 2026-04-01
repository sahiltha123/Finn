import '../entities/insights_entity.dart';

class GenerateFinnTips {
  const GenerateFinnTips();

  List<String> call(InsightsEntity insights) => insights.tips;
}
