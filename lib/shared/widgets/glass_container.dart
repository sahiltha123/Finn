import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.blurSigma = 16.0,
    this.borderOpacity = 0.15,
    this.backgroundOpacity = 0.1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final double borderOpacity;
  final double backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = colors.brightness == Brightness.dark;
    
    // Crisp clean background: pure white in light mode, elevated dark grey in dark mode
    final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderBase = isDark ? Colors.white : Colors.black;
    final radius = borderRadius ?? BorderRadius.circular(24);

    return Padding(
      padding: margin,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: radius,
          border: Border.all(
            color: borderBase.withValues(alpha: isDark ? 0.08 : 0.06),
            width: 1.0,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}
