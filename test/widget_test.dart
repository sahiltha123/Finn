import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finn/core/utils/local_notification_service.dart';
import 'package:finn/core/utils/messaging_service.dart';
import 'package:finn/core/utils/weekly_summary_service.dart';
import 'package:finn/main.dart';
import 'package:finn/shared/providers/user_provider.dart';

void main() {
  testWidgets('Finn app boots to onboarding for a fresh user', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final sessionController = AppSessionController(
      preferences,
      MockFirebaseAuth(),
      FakeFirebaseFirestore(),
      const MessagingService.noop(),
      WeeklySummaryService(
        preferences: preferences,
        firestore: FakeFirebaseFirestore(),
        notificationService: const LocalNotificationService.noop(),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appSessionProvider.overrideWith((ref) => sessionController),
        ],
        child: const FinnApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Know where every rupee goes'), findsOneWidget);
  });
}
