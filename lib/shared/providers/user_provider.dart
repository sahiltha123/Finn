import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../core/utils/messaging_service.dart';
import '../../core/utils/weekly_summary_service.dart';
import '../models/app_settings.dart';
import '../models/currency_info.dart';
import 'firebase_providers.dart';
import 'service_providers.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences was not overridden.'),
);

final weeklySummaryServiceProvider = Provider<WeeklySummaryService>((ref) {
  return WeeklySummaryService(
    preferences: ref.watch(sharedPreferencesProvider),
    firestore: ref.watch(firestoreProvider),
    notificationService: ref.watch(localNotificationServiceProvider),
  );
});

final appSessionProvider = ChangeNotifierProvider<AppSessionController>((ref) {
  return AppSessionController(
    ref.watch(sharedPreferencesProvider),
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(messagingServiceProvider),
    ref.watch(weeklySummaryServiceProvider),
  );
});

final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(appSessionProvider).currentUser,
);

class AppSessionController extends ChangeNotifier {
  AppSessionController(
    this._preferences,
    this._auth,
    this._firestore,
    this._messagingService,
    this._weeklySummaryService,
  ) {
    _hydrateLocalState();
    final existingUser = _auth.currentUser;
    if (existingUser == null) {
      _initialized = true;
      notifyListeners();
    } else {
      _setPlaceholderUser(existingUser);
    }

    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthChanged,
      onError: (error, stackTrace) {
        _initialized = true;
        notifyListeners();
      },
    );

    if (existingUser != null) {
      unawaited(_handleAuthChanged(existingUser));
    }
  }

  static const _onboardingKey = 'finn_onboarding_complete_v1';
  static const _themeModeKey = 'finn_dark_mode_v1';
  static const _currencyCodeKey = 'finn_currency_code_v1';
  static const _biometricLockKey = 'finn_biometric_lock_v1';
  static const _notificationsKey = 'finn_notifications_v1';

  final SharedPreferences _preferences;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final MessagingService _messagingService;
  final WeeklySummaryService _weeklySummaryService;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  bool _initialized = false;
  bool _onboardingComplete = false;
  bool _hasSelectedCurrency = false;
  ThemeMode _themeMode = ThemeMode.light;
  CurrencyInfo _selectedCurrency = CurrencyInfo.defaultCurrency;
  AppSettings _settings = AppSettings.defaults;
  AppUser? _currentUser;

  bool get initialized => _initialized;
  bool get onboardingComplete => _onboardingComplete;
  bool get hasSelectedCurrency => _hasSelectedCurrency;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get biometricEnabled => _settings.biometricLock;
  ThemeMode get themeMode => _themeMode;
  CurrencyInfo get selectedCurrency => _selectedCurrency;
  AppUser? get currentUser => _currentUser;
  AppSettings get settings => _settings;

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await _preferences.setBool(_onboardingKey, true);
    final user = _auth.currentUser;
    if (user != null) {
      await _userDocument(user.uid).set({
        'profile': {'onboardingComplete': true},
      }, SetOptions(merge: true));
    }
    notifyListeners();
  }

  Future<void> selectCurrency(CurrencyInfo currency) async {
    _selectedCurrency = currency;
    _hasSelectedCurrency = true;
    await _preferences.setString(_currencyCodeKey, currency.code);
    final user = _auth.currentUser;
    if (user != null) {
      await _userDocument(user.uid).set({
        'profile': {
          'currency': currency.code,
          'currencySymbol': currency.symbol,
        },
      }, SetOptions(merge: true));
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _settings = _settings.copyWith(darkMode: mode == ThemeMode.dark);
    await _preferences.setBool(_themeModeKey, mode == ThemeMode.dark);
    await _persistSettingsIfSignedIn();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _preferences.setBool(_notificationsKey, enabled);
    await _persistSettingsIfSignedIn();
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _settings = _settings.copyWith(biometricLock: enabled);
    await _preferences.setBool(_biometricLockKey, enabled);
    await _persistSettingsIfSignedIn();
    notifyListeners();
  }

  void _hydrateLocalState() {
    _onboardingComplete = _preferences.getBool(_onboardingKey) ?? false;
    final isDarkMode = _preferences.getBool(_themeModeKey) ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    final savedCurrencyCode = _preferences.getString(_currencyCodeKey);
    _hasSelectedCurrency = savedCurrencyCode != null;
    _selectedCurrency =
        CurrencyInfo.findByCode(savedCurrencyCode) ??
        CurrencyInfo.defaultCurrency;

    final biometricLock = _preferences.getBool(_biometricLockKey) ?? false;
    final notificationsEnabled = _preferences.getBool(_notificationsKey) ?? true;

    _settings = AppSettings.defaults.copyWith(
      darkMode: isDarkMode,
      biometricLock: biometricLock,
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> _handleAuthChanged(User? firebaseUser) async {
    await _userSubscription?.cancel();
    _userSubscription = null;
    if (firebaseUser == null) {
      _currentUser = null;
      _initialized = true;
      notifyListeners();
      return;
    }

    _setPlaceholderUser(firebaseUser);

    _userSubscription = _userDocument(firebaseUser.uid).snapshots().listen((
      snapshot,
    ) {
      final data = snapshot.data() ?? const <String, dynamic>{};
      final profile = Map<String, Object?>.from(
        (data['profile'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      );
      final settings = Map<String, Object?>.from(
        (data['settings'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
      );

      if (profile.isNotEmpty) {
        final user = UserModel.fromMap({'uid': firebaseUser.uid, ...profile});
        _currentUser = user;
        _selectedCurrency =
            CurrencyInfo.findByCode(user.currencyCode) ?? _selectedCurrency;
        _hasSelectedCurrency = true;
        _onboardingComplete = user.onboardingComplete;
        _preferences.setString(_currencyCodeKey, _selectedCurrency.code);
        _preferences.setBool(_onboardingKey, _onboardingComplete);
      } else {
        _currentUser = null;
      }

      _settings = AppSettings.fromMap(settings);
      _themeMode = _settings.darkMode ? ThemeMode.dark : ThemeMode.light;
      _preferences.setBool(_themeModeKey, _settings.darkMode);
      _preferences.setBool(_biometricLockKey, _settings.biometricLock);
      _preferences.setBool(_notificationsKey, _settings.notificationsEnabled);
      _initialized = true;
      notifyListeners();

      final currentUser = _currentUser;
      if (currentUser != null) {
        unawaited(
          _weeklySummaryService.notifyIfNeeded(
            uid: currentUser.uid,
            currencySymbol: currentUser.currencySymbol,
            notificationsEnabled: _settings.notificationsEnabled,
          ),
        );
      }
    }, onError: (error, stackTrace) {
      _initialized = true;
      notifyListeners();
    });

    unawaited(_syncMessagingToken(firebaseUser.uid));
  }

  void _setPlaceholderUser(User firebaseUser) {
    _currentUser = UserModel(
      uid: firebaseUser.uid,
      name:
          firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!.trim()
          : _fallbackName(firebaseUser.email),
      email: firebaseUser.email ?? '',
      currencyCode: _selectedCurrency.code,
      currencySymbol: _selectedCurrency.symbol,
      avatarColorHex: '0xFF1A73E8',
      onboardingComplete: _onboardingComplete,
      createdAt: DateTime.now(),
      fcmToken: null,
    );
    _initialized = true;
    notifyListeners();
  }

  String _fallbackName(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Finn User';
    }
    return email.split('@').first;
  }

  Future<void> _syncMessagingToken(String uid) async {
    try {
      final token = await _messagingService.token().timeout(
        const Duration(seconds: 5),
      );
      if (token == null) return;
      await _userDocument(uid).set({
        'profile': {'fcmToken': token},
      }, SetOptions(merge: true));
    } catch (_) {
      // Keep startup resilient even if FCM token retrieval or sync is slow.
    }
  }

  Future<void> _persistSettingsIfSignedIn() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _userDocument(
      user.uid,
    ).set({'settings': _settings.toMap()}, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
