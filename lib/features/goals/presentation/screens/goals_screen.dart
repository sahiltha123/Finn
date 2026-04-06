import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/finn_empty_state.dart';
import '../../../../shared/widgets/finn_error_widget.dart';
import '../../../../shared/widgets/finn_shimmer_list.dart';
import '../../../../shared/widgets/finn_snackbar.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_status.dart';
import '../../domain/entities/goal_type.dart';
import '../providers/goals_providers.dart';
import '../widgets/create_goal_sheet.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final currency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Finn Challenges')),
      body: goalsAsync.when(
        data: (goals) {
          final transactions = transactionsAsync.valueOrNull ?? const [];
          final active = goals
              .where(
                (goal) =>
                    goal.status(transactions, DateTime.now()) !=
                    GoalStatus.completed,
              )
              .toList();
          final completed = goals
              .where(
                (goal) =>
                    goal.status(transactions, DateTime.now()) ==
                    GoalStatus.completed,
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              Text(
                'Active challenges',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (goals.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: FinnEmptyState(
                    icon: Icons.flag_rounded,
                    title: AppStrings.noGoals,
                    message:
                        'Create a challenge to keep saving and spending with intention.',
                  ),
                )
              else ...[
                if (active.isEmpty)
                  const FinnEmptyState(
                    icon: Icons.flag_circle_rounded,
                    title: 'No active challenges',
                    message:
                        'Create one from the button below and Finn will keep score.',
                  )
                else
                  ...active.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GoalCard(
                        goal: goal,
                        transactions: transactions,
                        currency: currency,
                        onDelete: () => _deleteGoal(goal.id),
                        onAddProgress: goal.type == GoalType.savings
                            ? () => _updateSavingsProgress(goal)
                            : null,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Completed challenges'),
                  trailing: Icon(
                    _showCompleted
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                  onTap: () => setState(() => _showCompleted = !_showCompleted),
                ),
                if (_showCompleted)
                  ...completed.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GoalCard(
                        goal: goal,
                        transactions: transactions,
                        currency: currency,
                        onDelete: () => _deleteGoal(goal.id),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
        loading: () => const FinnShimmerList(itemCount: 4),
        error: (error, stackTrace) => FinnErrorWidget(
          message: 'Failed to load Finn Challenges.',
          onRetry: () => ref.invalidate(goalsProvider),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: FloatingActionButton.extended(
          onPressed: _openCreateGoalSheet,
          icon: const Icon(Icons.flag_rounded),
          label: const Text('Create'),
        ),
      ),
    );
  }

  void _openCreateGoalSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => CreateGoalSheet(
        onCreate: (goal) async {
          final user = ref.read(currentUserProvider);
          if (user == null) return;
          final result = await ref.read(createGoalUseCaseProvider)(
            uid: user.uid,
            goal: goal,
          );
          if (!context.mounted) return;
          result.fold(
            (failure) => showFinnSnackBar(context, message: failure.message),
            (_) async {
              await HapticFeedback.lightImpact();
              if (!context.mounted) return;
              showFinnSnackBar(context, message: 'Challenge created');
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteGoal(String goalId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await HapticFeedback.mediumImpact();
    final result = await ref.read(deleteGoalUseCaseProvider)(
      uid: user.uid,
      goalId: goalId,
    );
    result.fold(
      (failure) => showFinnSnackBar(context, message: failure.message),
      (_) => showFinnSnackBar(context, message: 'Challenge deleted'),
    );
  }

  Future<void> _updateSavingsProgress(GoalEntity goal) async {
    final controller = TextEditingController(
      text: (goal.currentAmount ?? 0).toStringAsFixed(0),
    );

    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${goal.title}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Current amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(double.tryParse(controller.text));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (value == null) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final result = await ref.read(updateGoalProgressUseCaseProvider)(
      uid: user.uid,
      goal: goal.copyWith(currentAmount: value, updatedAt: DateTime.now()),
    );

    result.fold(
      (failure) => showFinnSnackBar(context, message: failure.message),
      (_) async {
        await HapticFeedback.lightImpact();
        if (!mounted) return;
        showFinnSnackBar(context, message: 'Challenge updated');
      },
    );
  }
}
