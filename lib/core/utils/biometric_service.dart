import 'package:local_auth/local_auth.dart';

class BiometricService {
  const BiometricService(this._localAuthentication);

  final LocalAuthentication _localAuthentication;

  Future<bool> canAuthenticate() async {
    final supported = await _localAuthentication.isDeviceSupported();
    final available = await _localAuthentication.getAvailableBiometrics();
    return supported && available.isNotEmpty;
  }

  Future<bool> authenticate() {
    return _localAuthentication.authenticate(
      localizedReason: 'Unlock Finn',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}
