class AmountValidator {
  const AmountValidator._();

  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value.replaceAll(',', '').trim());
    if (amount == null) {
      return 'Enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    if (amount > 10000000) {
      return 'Amount exceeds maximum limit';
    }

    return null;
  }
}
