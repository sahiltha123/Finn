import '../entities/transaction_entity.dart';
import '../entities/transaction_category.dart';
import '../entities/transaction_type.dart';

class FilterTransactions {
  const FilterTransactions();

  List<TransactionEntity> call(
    List<TransactionEntity> transactions, {
    TransactionType? type,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return transactions.where((transaction) {
      final matchesType = type == null || transaction.type == type;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          transaction.category.label.toLowerCase().contains(normalizedQuery) ||
          (transaction.notes ?? '').toLowerCase().contains(normalizedQuery);
      return matchesType && matchesQuery;
    }).toList();
  }
}
