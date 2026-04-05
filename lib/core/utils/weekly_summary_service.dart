import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/domain/entities/transaction_type.dart';
import 'local_notification_service.dart';

class WeeklySummaryService {
  const WeeklySummaryService({
    required SharedPreferences preferences,
    required FirebaseFirestore firestore,
    required LocalNotificationService notificationService,
  }) : _preferences = preferences,
       _firestore = firestore,
       _notificationService = notificationService;

  static const _lastShownWeekKey = 'finn_last_weekly_summary_v1';

  final SharedPreferences _preferences;
  final FirebaseFirestore _firestore;
  final LocalNotificationService _notificationService;

  Future<void> notifyIfNeeded({
    required String uid,
    required String currencySymbol,
    required bool notificationsEnabled,
  }) async {
    if (!notificationsEnabled) {
      return;
    }

    final now = DateTime.now();
    final weekStart = _startOfWeek(now);
    final weekKey = _weekKey(weekStart);
    if (_preferences.getString(_lastShownWeekKey) == weekKey) {
      return;
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            weekStart.add(const Duration(days: 7)),
          ),
        )
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final transactions = snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
    final income = transactions
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (total, item) => total + item.amount);
    final expense = transactions
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (total, item) => total + item.amount);
    final savedAmount = (income - expense).clamp(0, double.infinity);

    await _notificationService.showWeeklySummary(
      '$currencySymbol${savedAmount.toStringAsFixed(0)}',
    );
    await _preferences.setString(_lastShownWeekKey, weekKey);
  }

  DateTime _startOfWeek(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    return start.subtract(Duration(days: start.weekday - 1));
  }

  String _weekKey(DateTime weekStart) {
    return '${weekStart.year}-${weekStart.month}-${weekStart.day}';
  }
}
