enum GoalStatus { onTrack, atRisk, completed, failed }

extension GoalStatusX on GoalStatus {
  String get label => switch (this) {
    GoalStatus.onTrack => 'On Track',
    GoalStatus.atRisk => 'At Risk',
    GoalStatus.completed => 'Crushed It',
    GoalStatus.failed => 'Missed',
  };

  String get firestoreValue => switch (this) {
    GoalStatus.onTrack => 'on_track',
    GoalStatus.atRisk => 'at_risk',
    GoalStatus.completed => 'completed',
    GoalStatus.failed => 'failed',
  };

  static GoalStatus fromFirestore(String? value) => switch (value) {
    'on_track' => GoalStatus.onTrack,
    'at_risk' => GoalStatus.atRisk,
    'completed' => GoalStatus.completed,
    'failed' => GoalStatus.failed,
    _ => GoalStatus.onTrack,
  };
}
