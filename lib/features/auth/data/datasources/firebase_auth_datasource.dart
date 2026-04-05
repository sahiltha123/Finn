import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/messaging_service.dart';
import '../../../../shared/models/app_settings.dart';
import '../../../../shared/models/currency_info.dart';
import '../models/user_model.dart';

class FirebaseAuthDatasource {
  FirebaseAuthDatasource(
    this._auth,
    this._firestore,
    this._googleSignIn,
    this._messagingService,
  );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final MessagingService _messagingService;
  final Random _random = Random();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Stream<UserModel?> watchAuthState() {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) {
        _currentUser = null;
        return Stream<UserModel?>.value(null);
      }

      return _userDocument(firebaseUser.uid).snapshots().map((snapshot) {
        final data = snapshot.data();
        if (data == null) {
          return null;
        }
        final profile = Map<String, Object?>.from(
          (data['profile'] as Map<String, Object?>?) ?? const {},
        );
        final user = UserModel.fromMap({'uid': firebaseUser.uid, ...profile});
        _currentUser = user;
        return user;
      });
    });
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Unable to sign in right now.');
      }
      await _ensureUserDocument(
        firebaseUser,
        currency: CurrencyInfo.defaultCurrency,
      );
      return _readUser(firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Email or password did not match.');
    }
  }

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required CurrencyInfo currency,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Unable to create your account.');
      }
      await firebaseUser.updateDisplayName(name.trim());
      await _ensureUserDocument(
        firebaseUser,
        name: name.trim(),
        currency: currency,
      );
      return _readUser(firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Unable to create your account.');
    }
  }

  Future<UserModel> signInWithGoogle({required CurrencyInfo currency}) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }

      final authentication = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthException('Unable to sign in with Google.');
      }

      await _ensureUserDocument(
        firebaseUser,
        name: firebaseUser.displayName ?? account.displayName ?? 'Finn User',
        currency: currency,
      );
      return _readUser(firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Unable to sign in with Google.');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> updateProfile({
    required String uid,
    String? currencyCode,
    String? currencySymbol,
    bool? onboardingComplete,
    String? fcmToken,
  }) {
    final updates = <String, Object?>{};
    if (currencyCode != null) {
      updates['profile.currency'] = currencyCode;
    }
    if (currencySymbol != null) {
      updates['profile.currencySymbol'] = currencySymbol;
    }
    if (onboardingComplete != null) {
      updates['profile.onboardingComplete'] = onboardingComplete;
    }
    if (fcmToken != null) {
      updates['profile.fcmToken'] = fcmToken;
    }
    return _userDocument(uid).set(updates, SetOptions(merge: true));
  }

  Future<void> updateSettings({
    required String uid,
    required AppSettings settings,
  }) {
    return _userDocument(
      uid,
    ).set({'settings': settings.toMap()}, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<void> _ensureUserDocument(
    User firebaseUser, {
    String? name,
    required CurrencyInfo currency,
  }) async {
    final snapshot = await _userDocument(firebaseUser.uid).get();
    final token = await _messagingService.token();
    if (snapshot.exists) {
      await _userDocument(firebaseUser.uid).set({
        'profile': {'fcmToken': token},
      }, SetOptions(merge: true));
      return;
    }

    await _userDocument(firebaseUser.uid).set({
      'profile': {
        'name': name ?? firebaseUser.displayName ?? 'Finn User',
        'email': firebaseUser.email ?? '',
        'currency': currency.code,
        'currencySymbol': currency.symbol,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'avatarColor': _randomAvatarColor(),
        'onboardingComplete': true,
        'fcmToken': token,
      },
      'settings': AppSettings.defaults.toMap(),
    });
  }

  Future<UserModel> _readUser(User firebaseUser) async {
    final snapshot = await _userDocument(firebaseUser.uid).get();
    final data = snapshot.data();
    if (data == null) {
      throw const AuthException('Your profile could not be loaded.');
    }
    final user = UserModel.fromMap({
      'uid': firebaseUser.uid,
      ...Map<String, Object?>.from(data['profile'] as Map<String, Object?>),
    });
    _currentUser = user;
    return user;
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
