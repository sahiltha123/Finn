import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

class TransactionFirestoreDatasource {
  const TransactionFirestoreDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<TransactionModel>> watchTransactions(String uid) {
    return _collection(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> addTransaction(String uid, TransactionEntity transaction) {
    return _collection(
      uid,
    ).doc(transaction.id).set(TransactionModel.fromEntity(transaction).toMap());
  }

  Future<void> updateTransaction(
    String uid,
    TransactionEntity transaction,
  ) async {
    final document = _collection(uid).doc(transaction.id);
    final snapshot = await document.get();
    if (!snapshot.exists) {
      throw const StorageException('Transaction not found.');
    }
    await document.set(TransactionModel.fromEntity(transaction).toMap());
  }

  Future<void> deleteTransaction(String uid, String transactionId) {
    return _collection(uid).doc(transactionId).delete();
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('users').doc(uid).collection('transactions');
  }
}
