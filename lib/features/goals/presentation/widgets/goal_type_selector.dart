import 'package:flutter/material.dart';

import '../../domain/entities/goal_type.dart';

class GoalTypeSelector extends StatelessWidget {
  const GoalTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final GoalType selectedType;
  final ValueChanged<GoalType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: GoalType.values
          .map(
            (type) => ChoiceChip(
              label: Text(type.label),
              selected: selectedType == type,
              onSelected: (_) => onSelected(type),
            ),
          )
          .toList(),
    );
  }
}
