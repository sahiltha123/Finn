import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/providers/service_providers.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/widgets/finn_empty_state.dart';
import '../../../../shared/widgets/finn_error_widget.dart';
import '../../../../shared/widgets/finn_shimmer_list.dart';
import '../providers/insights_providers.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/finn_tip_card.dart';
import '../widgets/monthly_summary_cards.dart';
import '../widgets/six_month_sparkline.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/health_score_card.dart';
import '../../../transactions/domain/entities/transaction_category.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  String? _lastTrackedMonth;

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(insightsMonthProvider);
    final insightsAsync = ref.watch(insightsProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final tipsUseCase = ref.watch(generateFinnTipsUseCaseProvider);
    final monthString = DateFormatter.compactMonth(month);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: insightsAsync.when(
        data: (insights) {
          if (_lastTrackedMonth != monthString) {
            _lastTrackedMonth = monthString;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(analyticsServiceProvider).logInsightsViewed(monthString);
            });
          }
          final tips = tipsUseCase(insights);
          final hasData =
              insights.totalIncome > 0 ||
              insights.totalExpense > 0 ||
              insights.categoryBreakdown.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(insightsMonthProvider.notifier).state = DateTime(
                        month.year,
                        month.month - 1,
                        1,
                      );
                    },
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      DateFormatter.fullMonth(month),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(insightsMonthProvider.notifier).state = DateTime(
                        month.year,
                        month.month + 1,
                        1,
                      );
                    },
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!hasData)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: FinnEmptyState(
                    icon: Icons.insights_rounded,
                    title: 'No insights yet',
                    message:
                        'Log a few transactions and Finn will start surfacing trends.',
                  ),
                )
              else ...[
                ref
                    .watch(healthScoreProvider)
                    .when(
                      data: (score) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HealthScoreCard(score: score),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                MonthlySummaryCards(
                  income: insights.totalIncome,
                  expense: insights.totalExpense,
                  savingsRate: insights.savingsRate,
                  currency: currency,
                ),
                const SizedBox(height: 16),
                CategoryDonutChart(data: insights.categoryBreakdown),
                const SizedBox(height: 16),
                WeeklyBarChart(data: insights.weeklyBreakdown),
                const SizedBox(height: 16),
                SixMonthSparkline(values: insights.sixMonthNet, month: month),
                const SizedBox(height: 16),
                if (insights.topCategory != null)
                  Card(
                    child: ListTile(
                      leading: Icon(insights.topCategory!.icon),
                      title: Text('Top category'),
                      subtitle: Text(insights.topCategory!.label),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Finn tips',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FinnTipCard(tip: tip),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const FinnShimmerList(itemCount: 4),
        error: (error, stackTrace) => FinnErrorWidget(
          message: 'Failed to load insights for this month.',
          onRetry: () => ref.invalidate(insightsProvider),
        ),
      ),
    );
  }
}
