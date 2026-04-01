import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/user_provider.dart';
import '../../data/datasources/transaction_firestore_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/filter_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/watch_transactions.dart';

final transactionDatasourceProvider = Provider<TransactionFirestoreDatasource>((
  ref,
) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return TransactionFirestoreDatasource(preferences);
});

final transactionRepositoryProvider = Provider<TransactionRepositoryImpl>((
  ref,
) {
  final datasource = ref.watch(transactionDatasourceProvider);
  return TransactionRepositoryImpl(datasource);
});

final watchTransactionsUseCaseProvider = Provider<WatchTransactions>((ref) {
  return WatchTransactions(ref.watch(transactionRepositoryProvider));
});

final addTransactionUseCaseProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(ref.watch(transactionRepositoryProvider));
});

final updateTransactionUseCaseProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(transactionRepositoryProvider));
});

final filterTransactionsUseCaseProvider = Provider<FilterTransactions>(
  (ref) => const FilterTransactions(),
);

final transactionsProvider = StreamProvider((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(watchTransactionsUseCaseProvider)(uid: user.uid);
});
