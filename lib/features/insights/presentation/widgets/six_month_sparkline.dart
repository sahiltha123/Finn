import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/finn_card.dart';

class SixMonthSparkline extends StatelessWidget {
  const SixMonthSparkline({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return FinnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('6-month trend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List<FlSpot>.generate(
                      values.length,
                      (index) => FlSpot(index.toDouble(), values[index]),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    color: Theme.of(context).colorScheme.primary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
