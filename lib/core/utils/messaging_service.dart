import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  const MessagingService(this._messaging)
    : _initializeOverride = null,
      _tokenOverride = null;

  const MessagingService.noop()
    : _messaging = null,
      _initializeOverride = null,
      _tokenOverride = null;

  const MessagingService.test({
    Future<void> Function()? onInitialize,
    Future<String?> Function()? onToken,
  }) : _messaging = null,
       _initializeOverride = onInitialize,
       _tokenOverride = onToken;

  final FirebaseMessaging? _messaging;
  final Future<void> Function()? _initializeOverride;
  final Future<String?> Function()? _tokenOverride;

  Future<void> initialize() async {
    if (_initializeOverride != null) {
      await _initializeOverride();
      return;
    }
    if (_messaging == null) {
      return;
    }
    await _messaging.requestPermission();
    await _messaging.setAutoInitEnabled(true);
  }

  Future<String?> token() async {
    if (_tokenOverride != null) {
      return _tokenOverride();
    }
    return _messaging?.getToken();
  }
}
