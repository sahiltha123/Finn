import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/currency_info.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> watchAuthState();

  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required CurrencyInfo currency,
  });

  Future<Either<Failure, AppUser>> signInWithGoogle({
    required CurrencyInfo currency,
  });

  Future<Either<Failure, Unit>> signOut();
}
