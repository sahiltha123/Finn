import 'package:flutter/material.dart';

enum FinnButtonVariant { primary, secondary, ghost, danger }

class FinnButton extends StatelessWidget {
  const FinnButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FinnButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final FinnButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = switch (variant) {
      FinnButtonVariant.primary => colors.onPrimary,
      FinnButtonVariant.secondary => colors.primary,
      FinnButtonVariant.ghost => colors.onSurface,
      FinnButtonVariant.danger => colors.onError,
    };
    final background = switch (variant) {
      FinnButtonVariant.primary => colors.primary,
      FinnButtonVariant.secondary => colors.primary.withValues(alpha: 0.1),
      FinnButtonVariant.ghost => Colors.transparent,
      FinnButtonVariant.danger => colors.error,
    };
    final side = switch (variant) {
      FinnButtonVariant.primary => BorderSide.none,
      FinnButtonVariant.secondary => BorderSide.none,
      FinnButtonVariant.ghost => BorderSide(color: colors.outline),
      FinnButtonVariant.danger => BorderSide.none,
    };

    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            side: side,
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: foreground,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
