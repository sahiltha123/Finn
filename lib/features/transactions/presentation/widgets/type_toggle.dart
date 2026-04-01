import 'package:flutter/material.dart';

import '../../domain/entities/transaction_type.dart';

class TypeToggle extends StatelessWidget {
  const TypeToggle({super.key, required this.value, required this.onChanged});

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      showSelectedIcon: false,
      segments: TransactionType.values
          .map(
            (type) => ButtonSegment<TransactionType>(
              value: type,
              label: Text(type.label),
            ),
          )
          .toList(),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
