class TransactionValidator {
  const TransactionValidator._();

  static String? validateNotes(String? value) {
    if (value != null && value.length > 120) {
      return 'Keep notes under 120 characters';
    }
    return null;
  }
}
