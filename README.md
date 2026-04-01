# Finn

Finn is a polished Flutter personal finance companion built around the master prompt in [`finn_master_prompt.md`](./finn_master_prompt.md).

This repo now includes:

- A calm custom design system with light and dark themes
- Onboarding, currency selection, login, register, and profile flows
- Bottom navigation with Home, Transactions, Goals, and Insights
- Local demo-mode repositories for transactions and goals using `SharedPreferences`
- Dashboard summaries, charts, Finn Challenges, and monthly insights
- Riverpod state management and GoRouter-based app flow

## Run

```bash
flutter pub get
flutter run
```

## Validation

```bash
flutter analyze
flutter test
```

## Current Scope

The app is intentionally wired in a demo/local-data mode so it runs without Firebase project files. The feature architecture is ready for the next step of replacing the local datasources with Firebase Auth and Firestore implementations once platform config is available.

## Next Recommended Step

1. Add Firebase project configuration with `flutterfire configure`
2. Replace the demo auth/transaction/goal datasources with Firebase-backed versions
3. Add analytics, crashlytics, notifications, and auth providers from the master prompt
