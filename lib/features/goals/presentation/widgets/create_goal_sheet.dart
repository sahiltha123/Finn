import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators/amount_validator.dart';
import '../../../../core/utils/validators/goal_validator.dart';
import '../../../../shared/widgets/finn_button.dart';
import '../../../../shared/widgets/finn_text_field.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_type.dart';
import 'goal_type_selector.dart';

class CreateGoalSheet extends ConsumerStatefulWidget {
  const CreateGoalSheet({super.key, required this.onCreate});

  final ValueChanged<GoalEntity> onCreate;

  @override
  ConsumerState<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController(text: '0');
  GoalType _goalType = GoalType.savings;
  TransactionCategory _category = TransactionCategory.food;
  int _durationDays = 7;
  int _streakTarget = 7;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  String _icon = '🎯';
  String _colorHex = '0xFF1A73E8';
  int _step = 0;

  static const _icons = <String>['🎯', '🏖', '🔥', '🛍', '💡', '🌱'];
  static const _colors = <String>[
    '0xFF1A73E8',
    '0xFF34A853',
    '0xFFFF6B6B',
    '0xFFFFBE0B',
    '0xFF8338EC',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create challenge',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              if (_step == 0) ...[
                GoalTypeSelector(
                  selectedType: _goalType,
                  onSelected: (value) => setState(() => _goalType = value),
                ),
              ] else if (_step == 1) ...[
                FinnTextField(
                  controller: _titleController,
                  label: 'Title',
                  validator: GoalValidator.validateTitle,
                ),
                const SizedBox(height: 16),
                if (_goalType == GoalType.savings ||
                    _goalType == GoalType.budget) ...[
                  FinnTextField(
                    controller: _targetController,
                    label: _goalType == GoalType.savings
                        ? 'Target amount'
                        : 'Budget limit',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: AmountValidator.validate,
                  ),
                ],
                if (_goalType == GoalType.savings) ...[
                  const SizedBox(height: 16),
                  FinnTextField(
                    controller: _currentController,
                    label: 'Current amount',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: AmountValidator.validate,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Deadline'),
                    subtitle: Text(
                      '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                    ),
                    trailing: const Icon(Icons.calendar_month_rounded),
                    onTap: _pickDeadline,
                  ),
                ],
                if (_goalType == GoalType.budget ||
                    _goalType == GoalType.noSpend) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TransactionCategory>(
                    initialValue: _category,
                    items: TransactionCategory.values
                        .where((item) => item.defaultType.name == 'expense')
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ],
                if (_goalType == GoalType.noSpend) ...[
                  const SizedBox(height: 16),
                  Slider(
                    value: _durationDays.toDouble(),
                    min: 3,
                    max: 21,
                    divisions: 18,
                    label: '$_durationDays days',
                    onChanged: (value) {
                      setState(() => _durationDays = value.round());
                    },
                  ),
                  Text('$_durationDays day challenge'),
                ],
                if (_goalType == GoalType.streak) ...[
                  const SizedBox(height: 16),
                  Slider(
                    value: _streakTarget.toDouble(),
                    min: 3,
                    max: 30,
                    divisions: 27,
                    label: '$_streakTarget days',
                    onChanged: (value) {
                      setState(() => _streakTarget = value.round());
                    },
                  ),
                  Text('Target streak: $_streakTarget days'),
                ],
              ] else ...[
                Text(
                  'Pick a mood for this challenge',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: _icons
                      .map(
                        (icon) => ChoiceChip(
                          label: Text(icon),
                          selected: _icon == icon,
                          onSelected: (_) => setState(() => _icon = icon),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: _colors
                      .map(
                        (value) => GestureDetector(
                          onTap: () => setState(() => _colorHex = value),
                          child: CircleAvatar(
                            radius: _colorHex == value ? 18 : 16,
                            backgroundColor: Color(
                              int.parse(
                                value.replaceFirst('0x', ''),
                                radix: 16,
                              ),
                            ),
                            child: _colorHex == value
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: FinnButton(
                        label: 'Back',
                        onPressed: () => setState(() => _step -= 1),
                        variant: FinnButtonVariant.secondary,
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FinnButton(
                      label: _step == 2 ? 'Create' : 'Next',
                      onPressed: _step == 2 ? _submit : _nextStep,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_step == 1 && !_formKey.currentState!.validate()) return;
    setState(() => _step += 1);
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    widget.onCreate(
      GoalEntity(
        id: 'goal_${now.microsecondsSinceEpoch}',
        title: _titleController.text.trim(),
        type: _goalType,
        targetAmount:
            (_goalType == GoalType.savings || _goalType == GoalType.budget)
            ? double.tryParse(_targetController.text)
            : null,
        currentAmount: _goalType == GoalType.savings
            ? double.tryParse(_currentController.text)
            : null,
        deadline: _goalType == GoalType.savings ? _deadline : null,
        category: _goalType == GoalType.budget || _goalType == GoalType.noSpend
            ? _category
            : null,
        durationDays: _goalType == GoalType.noSpend ? _durationDays : null,
        startDate: _goalType == GoalType.noSpend ? now : null,
        streakTarget: _goalType == GoalType.streak ? _streakTarget : null,
        icon: _icon,
        colorHex: _colorHex,
        createdAt: now,
        updatedAt: now,
      ),
    );
    Navigator.of(context).pop();
  }
}
