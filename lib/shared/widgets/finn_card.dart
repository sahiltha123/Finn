import 'package:flutter/material.dart';

import 'glass_container.dart';

class FinnCard extends StatelessWidget {
  const FinnCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(padding: padding, margin: margin, child: child);
  }
}
