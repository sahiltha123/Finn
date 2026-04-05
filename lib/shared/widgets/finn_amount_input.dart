import 'package:flutter/material.dart';

import '../models/currency_info.dart';
import 'finn_text_field.dart';

class FinnAmountInput extends StatelessWidget {
  const FinnAmountInput({
    super.key,
    this.name,
    required this.controller,
    required this.currency,
    this.validator,
  });

  final String? name;
  final TextEditingController controller;
  final CurrencyInfo currency;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return FinnTextField(
      name: name,
      controller: controller,
      label: 'Amount',
      hint: '0.00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      prefix: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          widthFactor: 1,
          child: Text(
            currency.symbol,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
