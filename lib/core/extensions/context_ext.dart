import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  GoRouter get router => GoRouter.of(this);
}
