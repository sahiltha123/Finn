import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/finn_card.dart';
import '../../../transactions/domain/entities/transaction_category.dart';

class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({super.key, required this.data});

  final Map<TransactionCategory, double> data;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return FinnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category split',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 42,
                sections: entries
                    .map(
                      (entry) => PieChartSectionData(
                        value: entry.value,
                        color: entry.key.color,
                        title: '${entry.value.round()}',
                        radius: 54,
                        titleStyle: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: entries
                .map(
                  (entry) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: entry.key.color),
                      const SizedBox(width: 6),
                      Text(entry.key.label),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
