import 'package:flutter/material.dart';

class FinnProgressRing extends StatelessWidget {
  const FinnProgressRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 72,
    this.strokeWidth = 8,
    this.color,
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: clamped,
            strokeWidth: strokeWidth,
            backgroundColor: Theme.of(context).colorScheme.outline,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
