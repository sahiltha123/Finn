import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/currency_info.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/watch_auth_state.dart';

final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return FirebaseAuthDatasource(preferences);
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final datasource = ref.watch(firebaseAuthDatasourceProvider);
  return AuthRepositoryImpl(datasource);
});

final watchAuthStateUseCaseProvider = Provider<WatchAuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return WatchAuthState(repository);
});

final signInWithEmailUseCaseProvider = Provider<SignInWithEmail>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithEmail(repository);
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogle>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogle(repository);
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmail>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpWithEmail(repository);
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOut(repository);
});

final authStateProvider = StreamProvider((ref) {
  final watchAuthState = ref.watch(watchAuthStateUseCaseProvider);
  return watchAuthState();
});

final authActionProvider =
    StateNotifierProvider<AuthActionController, AsyncValue<void>>((ref) {
      return AuthActionController(
        ref.watch(signInWithEmailUseCaseProvider),
        ref.watch(signUpWithEmailUseCaseProvider),
        ref.watch(signInWithGoogleUseCaseProvider),
        ref.watch(signOutUseCaseProvider),
      );
    });

class AuthActionController extends StateNotifier<AsyncValue<void>> {
  AuthActionController(
    this._signInWithEmail,
    this._signUpWithEmail,
    this._signInWithGoogle,
    this._signOut,
  ) : super(const AsyncValue.data(null));

  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  Future<Failure?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _signInWithEmail(email: email, password: password);
    return result.fold(_setFailure, (_) => _setSuccess());
  }

  Future<Failure?> signUp({
    required String name,
    required String email,
    required String password,
    required CurrencyInfo currency,
  }) async {
    state = const AsyncLoading();
    final result = await _signUpWithEmail(
      name: name,
      email: email,
      password: password,
      currency: currency,
    );
    return result.fold(_setFailure, (_) => _setSuccess());
  }

  Future<Failure?> signInWithGoogle({required CurrencyInfo currency}) async {
    state = const AsyncLoading();
    final result = await _signInWithGoogle(currency: currency);
    return result.fold(_setFailure, (_) => _setSuccess());
  }

  Future<Failure?> signOut() async {
    state = const AsyncLoading();
    final result = await _signOut();
    return result.fold(_setFailure, (_) => _setSuccess());
  }

  Failure _setFailure(Failure failure) {
    state = AsyncValue.error(failure, StackTrace.current);
    return failure;
  }

  Failure? _setSuccess() {
    state = const AsyncValue.data(null);
    return null;
  }
}
