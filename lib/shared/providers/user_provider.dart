import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../models/currency_info.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences was not overridden.'),
);

final appSessionProvider = ChangeNotifierProvider<AppSessionController>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final authRepository = AuthRepositoryImpl(
    FirebaseAuthDatasource(preferences),
  );
  return AppSessionController(preferences, authRepository);
});

final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(appSessionProvider).currentUser,
);

class AppSessionController extends ChangeNotifier {
  AppSessionController(this._preferences, this._authRepository) {
    _hydrate();
    _authSubscription = _authRepository.watchAuthState().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  static const _onboardingKey = 'finn_onboarding_complete_v1';
  static const _themeModeKey = 'finn_dark_mode_v1';
  static const _currencyCodeKey = 'finn_currency_code_v1';
  static const _notificationsKey = 'finn_notifications_v1';
  static const _biometricKey = 'finn_biometric_v1';

  final SharedPreferences _preferences;
  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _authSubscription;

  bool _initialized = false;
  bool _onboardingComplete = false;
  bool _hasSelectedCurrency = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  ThemeMode _themeMode = ThemeMode.light;
  CurrencyInfo _selectedCurrency = CurrencyInfo.defaultCurrency;
  AppUser? _currentUser;

  bool get initialized => _initialized;
  bool get onboardingComplete => _onboardingComplete;
  bool get hasSelectedCurrency => _hasSelectedCurrency;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricEnabled => _biometricEnabled;
  ThemeMode get themeMode => _themeMode;
  CurrencyInfo get selectedCurrency => _selectedCurrency;
  AppUser? get currentUser => _currentUser;

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await _preferences.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> selectCurrency(CurrencyInfo currency) async {
    _selectedCurrency = currency;
    _hasSelectedCurrency = true;
    await _preferences.setString(_currencyCodeKey, currency.code);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _preferences.setBool(_themeModeKey, mode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _preferences.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    await _preferences.setBool(_biometricKey, enabled);
    notifyListeners();
  }

  void _hydrate() {
    _onboardingComplete = _preferences.getBool(_onboardingKey) ?? false;
    _notificationsEnabled = _preferences.getBool(_notificationsKey) ?? true;
    _biometricEnabled = _preferences.getBool(_biometricKey) ?? false;
    _themeMode = (_preferences.getBool(_themeModeKey) ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
    final savedCurrencyCode = _preferences.getString(_currencyCodeKey);
    _hasSelectedCurrency = savedCurrencyCode != null;
    _selectedCurrency =
        CurrencyInfo.findByCode(savedCurrencyCode) ??
        CurrencyInfo.defaultCurrency;
    _currentUser = _authRepository.currentUser;
    _initialized = true;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
