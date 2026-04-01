import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finn/main.dart';
import 'package:finn/shared/providers/user_provider.dart';

void main() {
  testWidgets('Finn app boots to onboarding for a fresh user', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const FinnApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Know where every rupee goes'), findsOneWidget);
  });
}
