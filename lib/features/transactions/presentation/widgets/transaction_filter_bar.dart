import 'package:flutter/material.dart';

import '../../domain/entities/transaction_type.dart';

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final TransactionType? selectedType;
  final ValueChanged<TransactionType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selectedType == null,
          onSelected: (_) => onTypeChanged(null),
        ),
        ...TransactionType.values.map(
          (type) => ChoiceChip(
            label: Text(type.label),
            selected: selectedType == type,
            onSelected: (_) => onTypeChanged(type),
          ),
        ),
      ],
    );
  }
}
