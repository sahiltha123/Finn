import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService(this._plugin) : _showOverride = null;

  const LocalNotificationService.noop() : _plugin = null, _showOverride = null;

  const LocalNotificationService.test({
    Future<void> Function({
      required int id,
      required String title,
      required String body,
    })?
    onShow,
  }) : _plugin = null,
       _showOverride = onShow;

  final FlutterLocalNotificationsPlugin? _plugin;
  final Future<void> Function({
    required int id,
    required String title,
    required String body,
  })?
  _showOverride;

  Future<void> initialize() async {
    if (_plugin == null) {
      return;
    }
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    if (_plugin == null) {
      return;
    }
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showGoalHalfway(String title) {
    return _show(
      id: 1001,
      title: 'Halfway there',
      body: "You're halfway to your $title goal! Keep going.",
    );
  }

  Future<void> showGoalCompleted(String title) {
    return _show(
      id: 1002,
      title: 'Goal completed',
      body: 'You crushed your $title goal!',
    );
  }

  Future<void> showBudgetAlert(String title) {
    return _show(
      id: 1003,
      title: 'Budget alert',
      body: "Heads up! You've used 80% of your $title budget.",
    );
  }

  Future<void> showWeeklySummary(String amountText) {
    return _show(
      id: 1004,
      title: 'Weekly summary',
      body: 'Your Finn weekly recap is ready. You saved $amountText this week.',
    );
  }

  Future<void> showStreakRisk() {
    return _show(
      id: 1005,
      title: 'Streak at risk',
      body: "Don't break your streak! Log a saving today.",
    );
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (_showOverride != null) {
      await _showOverride(id: id, title: title, body: body);
      return;
    }
    if (_plugin == null) {
      return;
    }
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'finn_general',
        'Finn alerts',
        channelDescription: 'Goal milestones and finance reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(id, title, body, details);
  }
}
