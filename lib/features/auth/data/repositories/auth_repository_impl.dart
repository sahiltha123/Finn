import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/currency_info.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final FirebaseAuthDatasource _datasource;

  @override
  AppUser? get currentUser => _datasource.currentUser;

  @override
  Stream<AppUser?> watchAuthState() => _datasource.watchAuthState();

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _datasource.signInWithEmail(
        email: email,
        password: password,
      );
      return right(result);
    } on AuthException catch (error) {
      return left(AuthFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to sign in right now.'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle({
    required CurrencyInfo currency,
  }) async {
    try {
      final result = await _datasource.signInWithGoogle(currency: currency);
      return right(result);
    } on AuthException catch (error) {
      return left(AuthFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Google sign-in is unavailable.'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required CurrencyInfo currency,
  }) async {
    try {
      final result = await _datasource.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        currency: currency,
      );
      return right(result);
    } on AuthException catch (error) {
      return left(AuthFailure(error.message));
    } catch (_) {
      return left(const UnknownFailure('Unable to create your account.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _datasource.signOut();
      return right(unit);
    } catch (_) {
      return left(const UnknownFailure('Unable to sign out right now.'));
    }
  }
}
