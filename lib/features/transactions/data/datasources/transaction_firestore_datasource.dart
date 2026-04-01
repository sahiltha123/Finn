import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';
import '../models/transaction_model.dart';

class TransactionFirestoreDatasource {
  TransactionFirestoreDatasource(this._preferences);

  final SharedPreferences _preferences;
  final Map<String, StreamController<List<TransactionModel>>> _controllers =
      <String, StreamController<List<TransactionModel>>>{};

  Stream<List<TransactionModel>> watchTransactions(String uid) {
    final controller = _controllers.putIfAbsent(
      uid,
      () => StreamController<List<TransactionModel>>.broadcast(),
    );
    controller.add(_read(uid));
    return controller.stream;
  }

  Future<void> addTransaction(String uid, TransactionEntity transaction) async {
    final items = _read(uid);
    items.add(TransactionModel.fromEntity(transaction));
    await _save(uid, items);
  }

  Future<void> updateTransaction(
    String uid,
    TransactionEntity transaction,
  ) async {
    final items = _read(uid);
    final index = items.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      throw const StorageException('Transaction not found.');
    }
    items[index] = TransactionModel.fromEntity(transaction);
    await _save(uid, items);
  }

  Future<void> deleteTransaction(String uid, String transactionId) async {
    final items = _read(uid);
    items.removeWhere((item) => item.id == transactionId);
    await _save(uid, items);
  }

  List<TransactionModel> _read(String uid) {
    final raw = _preferences.getString(_storageKey(uid));
    if (raw == null) {
      final seeded = _seedTransactions();
      _preferences.setString(
        _storageKey(uid),
        jsonEncode(seeded.map((item) => item.toMap()).toList()),
      );
      return seeded;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final items = decoded
        .map((item) => TransactionModel.fromMap(item as Map<String, dynamic>))
        .toList();
    items.sort((left, right) => right.date.compareTo(left.date));
    return items;
  }

  Future<void> _save(String uid, List<TransactionModel> items) async {
    items.sort((left, right) => right.date.compareTo(left.date));
    await _preferences.setString(
      _storageKey(uid),
      jsonEncode(items.map((item) => item.toMap()).toList()),
    );
    _controllers[uid]?.add(items);
  }

  String _storageKey(String uid) => 'finn_transactions_$uid';

  List<TransactionModel> _seedTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'txn_salary',
        amount: 65000,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: now.subtract(const Duration(days: 6)),
        notes: 'Monthly salary',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      TransactionModel(
        id: 'txn_food',
        amount: 320,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 1)),
        notes: 'Dinner with friends',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: 'txn_transport',
        amount: 180,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: now.subtract(const Duration(days: 2)),
        notes: 'Metro card top-up',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      TransactionModel(
        id: 'txn_shopping',
        amount: 2400,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: now.subtract(const Duration(days: 3)),
        notes: 'Running shoes',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: 'txn_savings',
        amount: 6000,
        type: TransactionType.income,
        category: TransactionCategory.savings,
        date: now.subtract(const Duration(days: 4)),
        notes: 'Moved to rainy day fund',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      TransactionModel(
        id: 'txn_bills',
        amount: 1200,
        type: TransactionType.expense,
        category: TransactionCategory.bills,
        date: now.subtract(const Duration(days: 5)),
        notes: 'Electricity bill',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}
