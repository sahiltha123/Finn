enum GoalType { savings, noSpend, budget, streak }

extension GoalTypeX on GoalType {
  String get label => switch (this) {
    GoalType.savings => 'Savings',
    GoalType.noSpend => 'No-spend',
    GoalType.budget => 'Budget',
    GoalType.streak => 'Streak',
  };
}
