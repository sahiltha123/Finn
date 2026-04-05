import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/utils/validators/amount_validator.dart';
import '../../../../core/utils/validators/transaction_validator.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/finn_amount_input.dart';
import '../../../../shared/widgets/finn_button.dart';
import '../../../../shared/widgets/finn_text_field.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/transaction_providers.dart';
import 'category_picker_grid.dart';
import 'type_toggle.dart';

class AddEditTransactionSheet extends ConsumerStatefulWidget {
  const AddEditTransactionSheet({super.key, this.transaction});

  final TransactionEntity? transaction;

  @override
  ConsumerState<AddEditTransactionSheet> createState() =>
      _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState
    extends ConsumerState<AddEditTransactionSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late TransactionType _type;
  late TransactionCategory _category;
  late DateTime _date;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.transaction;
    _amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _type = existing?.type ?? TransactionType.expense;
    _category = existing?.category ?? TransactionCategory.food;
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(selectedCurrencyProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.transaction == null
                    ? 'Add transaction'
                    : 'Edit transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              FinnAmountInput(
                name: 'amount',
                controller: _amountController,
                currency: currency,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Amount is required',
                  ),
                  AmountValidator.validate,
                ]),
              ),
              const SizedBox(height: 16),
              TypeToggle(
                value: _type,
                onChanged: (type) {
                  setState(() {
                    _type = type;
                    final categories = TransactionCategoryX.forType(type);
                    if (!categories.contains(_category)) {
                      _category = categories.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              CategoryPickerGrid(
                type: _type,
                selectedCategory: _category,
                onSelected: (category) => setState(() => _category = category),
              ),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_month_rounded),
                  ),
                  child: Text('${_date.day}/${_date.month}/${_date.year}'),
                ),
              ),
              const SizedBox(height: 16),
              FinnTextField(
                name: 'notes',
                controller: _notesController,
                label: 'Notes',
                hint: 'Optional note',
                maxLines: 2,
                validator: TransactionValidator.validateNotes,
              ),
              const SizedBox(height: 24),
              FinnButton(
                label: widget.transaction == null
                    ? 'Save transaction'
                    : 'Update transaction',
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final now = DateTime.now();
    final transaction = TransactionEntity(
      id: widget.transaction?.id ?? 'txn_${now.microsecondsSinceEpoch}',
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.transaction?.createdAt ?? now,
      updatedAt: now,
      isRecurring: widget.transaction?.isRecurring ?? false,
    );

    setState(() => _isSaving = true);
    final result = widget.transaction == null
        ? await ref.read(addTransactionUseCaseProvider)(
            uid: user.uid,
            transaction: transaction,
          )
        : await ref.read(updateTransactionUseCaseProvider)(
            uid: user.uid,
            transaction: transaction,
          );
    setState(() => _isSaving = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) async {
        await HapticFeedback.lightImpact();
        if (!mounted) return;
        Navigator.of(context).pop();
      },
    );
  }
}
