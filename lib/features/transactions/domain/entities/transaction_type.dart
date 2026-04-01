enum TransactionType { income, expense }

extension TransactionTypeLabel on TransactionType {
  String get label => this == TransactionType.income ? 'Income' : 'Expense';
}
