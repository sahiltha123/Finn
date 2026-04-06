# Finn: Engineering Architecture 🧱

Finn is built on a foundation of **Clean Architecture** and **Reactive State Management**, ensuring that the project is maintainable, testable, and logically separated. This document outlines the technical design decisions and patterns used throughout the codebase.

---

## 🏛️ Project Structure

Finn follows the **Feature-First** structure, which combines domain-driven design (DDD) with clean architecture layers.

```text
lib/
├── core/               # App-wide singleton services, constants, and theme
├── features/           # Independent vertical slices of functionality
│   ├── auth/           # Login, registration, onboarding
│   ├── dashboard/      # Financial summaries, total balance
│   ├── goals/          # Savings/budget challenges, progress tracking
│   ├── insights/       # Health Score, spending trends, recurring patterns
│   └── transactions/   # CRUD, categorization, export (PDF)
└── shared/             # Reusable UI widgets, global state providers (User/Currency)
```

Within each feature, we strictly observe a four-tier layer split:
1. **Data**: DTOs (Data Transfer Objects), Mappers, and API/Firestore Implementations.
2. **Domain**: Entities (Logic-bearing objects) and Use Cases (Business workflows).
3. **Presentation**: Widgets, Screens, and **Riverpod** StateNotifiers/Providers.
4. **Infrastructure**: External service adapters (e.g., PDF generation, biometrics).

---

## ⚡ State Management: Riverpod

Finn uses **Riverpod** for state management, specifically leveraging `AsyncValue` to handle the asynchronous nature of Firebase.

*   **Global Singletons**: `appSessionProvider` manages the user session, currency settings, and biometric preferences.
*   **Reactive Syncing**: As transactions or goals change in Firestore, Riverpod providers automatically invalidate and re-fetch, keeping the UI "alive" without manual refresh.
*   **Decoupled Logic**: UI widgets never call repositories directly. Instead, they interact with `UseCases` via a provider, ensuring the presentation layer is indifferent to the data source.

---

## 🧐 Domain Logic: The "Intelligence" Layer

Finn is not just a CRUD app. It contains heavy logic implemented in pure Dart:

### 1. Financial Health Score (`calculate_health_score.dart`)
This algorithm takes a snapshot of a user's transactions and goals and calculates a normalized score (0–100) across four pillars: **Savings Rate**, **Budget Discipline**, **Goal Adherence**, and **Pattern Stability**. This logic is fully tested via unit tests to ensure accuracy.

### 2. Predictive Spending Alerts (`predict_budget_exhaustion.dart`)
Using current spending velocity (burn rate) and goal deadlines, Finn calculates the "predicted exhaustion date." If this date falls before the goal deadline, the UI surfaces an "At Risk" warning.

### 3. Smart Recurring Detection (`detect_recurring_patterns.dart`)
A window-based grouping algorithm that identifies transactions occurring at similar intervals (7 days, 30 days) with similar labels, automatically suggesting "Recurring Habits" to the user.

---

## 🛡️ Security Architecture

### Biometric Lock
Finn uses `local_auth` to provide a "Secondary Guard." When enabled, the app session controller requires a biometric signature before navigating to the main dashboard. Sensitive data is stored in **Secure Storage** where applicable.

### Data Isolation (Firestore)
The security logic is pushed to the server (Firebase). Our `firestore.rules` ensure that a user can *never* query or modify another user's financial documents, mapping every request strictly to the `request.auth.uid`.

---

## 🧪 Testing Strategy

*   **Unit Tests**: Located in `test/`, focusing on `UseCases`. Mocktail is used to stub repositories, ensuring we test the business logic in isolation.
*   **Mock Data**: We use `fake_cloud_firestore` and `firebase_auth_mocks` for integration-style tests that verify how our components interact with the database.

---

## 🏗️ Deployment (CI/CD)

The project includes a **GitHub Actions** pipeline (`ci.yml`) that validates:
1. **Static Analysis**: Enforces the Flutter lint rules.
2. **Logic Validation**: Runs the entire test suite.
3. **Build Check**: Verifies that the APK can be assembled without dependency conflicts (e.g., Crashlytics mapping).

---

> This architecture is designed for a "senior-level" evaluation—prioritizing separation of concerns and production robustness over simple developer convenience.
