import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../shared/models/currency_info.dart';
import '../models/user_model.dart';

class FirebaseAuthDatasource {
  FirebaseAuthDatasource(this._preferences) {
    _seedFromStorage();
  }

  static const _accountsKey = 'finn_auth_accounts_v1';
  static const _currentUserKey = 'finn_current_user_v1';

  final SharedPreferences _preferences;
  final StreamController<UserModel?> _authController =
      StreamController<UserModel?>.broadcast();
  final Random _random = Random();

  List<_StoredAccount> _accounts = <_StoredAccount>[];
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Stream<UserModel?> watchAuthState() => _authController.stream;

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    try {
      final account = _accounts.firstWhere(
        (item) =>
            item.user.email.toLowerCase() == email.trim().toLowerCase() &&
            item.password == password,
      );
      _currentUser = account.user;
      await _persistCurrentUser();
      _authController.add(_currentUser);
      return account.user;
    } on StateError {
      throw const AuthException('Email or password did not match.');
    }
  }

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required CurrencyInfo currency,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = email.trim().toLowerCase();
    final exists = _accounts.any(
      (item) => item.user.email.toLowerCase() == normalizedEmail,
    );
    if (exists) {
      throw const AuthException('An account with this email already exists.');
    }

    final user = UserModel(
      uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      avatarColorHex: _randomAvatarColor(),
      onboardingComplete: true,
      createdAt: DateTime.now(),
    );
    _accounts = [..._accounts, _StoredAccount(user: user, password: password)];
    _currentUser = user;
    await _persistAccounts();
    await _persistCurrentUser();
    _authController.add(_currentUser);
    return user;
  }

  Future<UserModel> signInWithGoogle({required CurrencyInfo currency}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final existing = _accounts.where(
      (item) => item.user.email == 'demo@finn.app',
    );
    if (existing.isNotEmpty) {
      _currentUser = existing.first.user;
    } else {
      final user = UserModel(
        uid: 'google_demo_user',
        name: 'Riya Finn',
        email: 'demo@finn.app',
        currencyCode: currency.code,
        currencySymbol: currency.symbol,
        avatarColorHex: _randomAvatarColor(),
        onboardingComplete: true,
        createdAt: DateTime.now(),
      );
      _accounts = [
        ..._accounts,
        _StoredAccount(user: user, password: 'google'),
      ];
      await _persistAccounts();
      _currentUser = user;
    }

    await _persistCurrentUser();
    _authController.add(_currentUser);
    return _currentUser!;
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _currentUser = null;
    await _preferences.remove(_currentUserKey);
    _authController.add(null);
  }

  void _seedFromStorage() {
    final accountsJson = _preferences.getString(_accountsKey);
    if (accountsJson != null) {
      final decoded = jsonDecode(accountsJson) as List<dynamic>;
      _accounts = decoded
          .map((item) => _StoredAccount.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    final currentUserJson = _preferences.getString(_currentUserKey);
    if (currentUserJson != null) {
      _currentUser = UserModel.fromMap(
        jsonDecode(currentUserJson) as Map<String, dynamic>,
      );
    }

    _authController.add(_currentUser);
  }

  Future<void> _persistAccounts() {
    final encoded = jsonEncode(_accounts.map((item) => item.toMap()).toList());
    return _preferences.setString(_accountsKey, encoded);
  }

  Future<void> _persistCurrentUser() async {
    if (_currentUser == null) {
      await _preferences.remove(_currentUserKey);
      return;
    }
    await _preferences.setString(
      _currentUserKey,
      jsonEncode(_currentUser!.toMap()),
    );
  }

  String _randomAvatarColor() {
    const colors = <String>[
      '0xFF1A73E8',
      '0xFF34A853',
      '0xFFFBBC04',
      '0xFFEA4335',
      '0xFF8338EC',
    ];
    return colors[_random.nextInt(colors.length)];
  }
}

class _StoredAccount {
  const _StoredAccount({required this.user, required this.password});

  final UserModel user;
  final String password;

  factory _StoredAccount.fromMap(Map<String, dynamic> map) {
    return _StoredAccount(
      user: UserModel.fromMap(map['user'] as Map<String, dynamic>),
      password: map['password']! as String,
    );
  }

  Map<String, Object?> toMap() {
    return {'user': user.toMap(), 'password': password};
  }
}
