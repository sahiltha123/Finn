import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/currency_info.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AppUser>> call({required CurrencyInfo currency}) {
    return _repository.signInWithGoogle(currency: currency);
  }
}
