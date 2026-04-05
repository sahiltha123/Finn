# Finn

Finn is a polished Flutter personal finance companion built around the master prompt in [`finn_master_prompt.md`](./finn_master_prompt.md).

This repo now includes:

- A calm custom design system with light and dark themes
- Onboarding, currency selection, login, register, and profile flows
- Bottom navigation with Home, Transactions, Goals, and Insights
- Firebase Auth email/password and Google Sign-In wiring
- Firestore-backed profile, settings, transactions, goals, and monthly insights cache
- Dashboard summaries, charts, Finn Challenges, and monthly insights
- Firebase Analytics, Crashlytics hooks, local notification automation, and biometric lock
- Riverpod state management and GoRouter-based app flow

## Run

```bash
flutter pub get
flutter run
```

Android Firebase config is already present in this repo. iOS runtime verification is still blocked until `ios/Runner/GoogleService-Info.plist` is added.

## Validation

```bash
flutter analyze
flutter test
```

## Current Scope

The app is now wired for a real Firebase-backed Android-first workflow:

- Firebase bootstrap with offline Firestore persistence
- Crashlytics error capture hooks
- Analytics event logging for transactions, goals, and insights
- Firestore security rules in [`firestore.rules`](./firestore.rules)
- Local notifications for goal milestones, budget alerts, weekly recap, and streak risk
- FormBuilder-driven auth, transaction, and goal-entry forms

## Remaining Setup Notes

1. Add `ios/Runner/GoogleService-Info.plist` if you want to validate on iOS.
2. Confirm Firebase console setup for Email/Password auth, Google Sign-In, Firestore, Analytics, Crashlytics, and FCM.
3. For production delivery, add release signing/SHA configuration for Google Sign-In and verify notification behavior on-device.
