import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/currency_info.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AppUser>> call({
    required String name,
    required String email,
    required String password,
    required CurrencyInfo currency,
  }) {
    return _repository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
      currency: currency,
    );
  }
}
