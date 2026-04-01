enum GoalStatus { onTrack, atRisk, completed, failed }

extension GoalStatusX on GoalStatus {
  String get label => switch (this) {
    GoalStatus.onTrack => 'On Track',
    GoalStatus.atRisk => 'At Risk',
    GoalStatus.completed => 'Crushed It',
    GoalStatus.failed => 'Missed',
  };
}
