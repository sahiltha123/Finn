import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/analytics_service.dart';
import '../../core/utils/biometric_service.dart';
import '../../core/utils/goal_automation_service.dart';
import '../../core/utils/local_notification_service.dart';
import '../../core/utils/messaging_service.dart';
import 'firebase_providers.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) =>
      throw UnimplementedError('LocalNotificationService was not overridden.'),
);

final messagingServiceProvider = Provider<MessagingService>(
  (ref) => throw UnimplementedError('MessagingService was not overridden.'),
);

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(ref.watch(firebaseAnalyticsProvider)),
);

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(ref.watch(localAuthenticationProvider)),
);

final goalAutomationServiceProvider = Provider<GoalAutomationService>(
  (ref) => GoalAutomationService(
    firestore: ref.watch(firestoreProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    notificationService: ref.watch(localNotificationServiceProvider),
  ),
);

final notificationPluginProvider = Provider<FlutterLocalNotificationsPlugin>(
  (ref) => FlutterLocalNotificationsPlugin(),
);
