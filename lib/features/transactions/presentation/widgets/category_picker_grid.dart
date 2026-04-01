import 'package:flutter/material.dart';

import '../../../../shared/widgets/finn_category_chip.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_type.dart';

class CategoryPickerGrid extends StatelessWidget {
  const CategoryPickerGrid({
    super.key,
    required this.type,
    required this.selectedCategory,
    required this.onSelected,
  });

  final TransactionType type;
  final TransactionCategory selectedCategory;
  final ValueChanged<TransactionCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = TransactionCategoryX.forType(type);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories
          .map(
            (category) => FinnCategoryChip(
              label: category.label,
              icon: category.icon,
              selected: category == selectedCategory,
              onSelected: (_) => onSelected(category),
            ),
          )
          .toList(),
    );
  }
}
