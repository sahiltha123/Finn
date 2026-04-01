import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_provider.dart';

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(appSessionProvider).themeMode,
);
