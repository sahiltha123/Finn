class GoalValidator {
  const GoalValidator._();

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Give this challenge a title';
    }
    if (value.trim().length < 3) {
      return 'Title is too short';
    }
    return null;
  }
}
