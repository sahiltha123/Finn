import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/goal_entity.dart';
import '../models/goal_model.dart';

class GoalsFirestoreDatasource {
  const GoalsFirestoreDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<GoalModel>> watchGoals(String uid) {
    return _collection(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GoalModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> createGoal(String uid, GoalEntity goal) {
    return _collection(
      uid,
    ).doc(goal.id).set(GoalModel.fromEntity(goal).toMap());
  }

  Future<void> updateGoal(String uid, GoalEntity goal) async {
    final document = _collection(uid).doc(goal.id);
    final snapshot = await document.get();
    if (!snapshot.exists) {
      throw const StorageException('Goal not found.');
    }
    await document.set(GoalModel.fromEntity(goal).toMap());
  }

  Future<void> deleteGoal(String uid, String goalId) {
    return _collection(uid).doc(goalId).delete();
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('users').doc(uid).collection('goals');
  }
}
