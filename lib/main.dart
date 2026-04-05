import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/local_notification_service.dart';
import 'core/utils/messaging_service.dart';
import 'firebase_options.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/service_providers.dart';
import 'shared/providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final preferences = await SharedPreferences.getInstance();
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final localNotificationService = LocalNotificationService(
    notificationsPlugin,
  );
  await localNotificationService.initialize();
  await localNotificationService.requestPermissions();
  final messagingService = MessagingService(FirebaseMessaging.instance);
  if (!kIsWeb) {
    await messagingService.initialize();
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        notificationPluginProvider.overrideWithValue(notificationsPlugin),
        localNotificationServiceProvider.overrideWithValue(
          localNotificationService,
        ),
        messagingServiceProvider.overrideWithValue(messagingService),
      ],
      child: const FinnApp(),
    ),
  );
}

class FinnApp extends ConsumerStatefulWidget {
  const FinnApp({super.key});

  @override
  ConsumerState<FinnApp> createState() => _FinnAppState();
}

class _FinnAppState extends ConsumerState<FinnApp> with WidgetsBindingObserver {
  bool _locked = false;
  bool _isAuthenticating = false;
  DateTime? _lastUnlockedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardBiometric());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _guardBiometric();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (_locked) _UnlockOverlay(onUnlock: _guardBiometric),
          ],
        );
      },
    );
  }

  Future<void> _guardBiometric() async {
    if (_isAuthenticating) return;

    // Grace period: If we successfully unlocked in the last 5 seconds,
    // don't try to lock again. This breaks the "Dismiss dialog -> Resumed -> Re-lock" loop.
    if (_lastUnlockedAt != null) {
      final now = DateTime.now();
      if (now.difference(_lastUnlockedAt!) < const Duration(seconds: 5)) {
        if (mounted && _locked) {
          setState(() => _locked = false);
        }
        return;
      }
    }

    final session = ref.read(appSessionProvider);
    if (!session.biometricEnabled || session.currentUser == null) {
      if (mounted && _locked) {
        setState(() => _locked = false);
      }
      return;
    }

    final biometricService = ref.read(biometricServiceProvider);
    final canAuthenticate = await biometricService.canAuthenticate();
    if (!canAuthenticate) {
      if (mounted && _locked) {
        setState(() => _locked = false);
      }
      return;
    }

    setState(() {
      _locked = true;
      _isAuthenticating = true;
    });

    try {
      final unlocked = await biometricService.authenticate();
      if (!mounted) return;
      setState(() {
        _locked = !unlocked;
        if (unlocked) {
          _lastUnlockedAt = DateTime.now();
        }
      });
    } finally {
      _isAuthenticating = false;
    }
  }
}

class _UnlockOverlay extends StatelessWidget {
  const _UnlockOverlay({required this.onUnlock});

  final Future<void> Function() onUnlock;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      'Finn is locked',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use your biometric authentication to continue.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: onUnlock,
                      child: const Text('Unlock'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
