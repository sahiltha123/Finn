import 'package:flutter/material.dart';

import 'finn_button.dart';

class FinnEmptyState extends StatelessWidget {
  const FinnEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onPressed != null) ...[
              const SizedBox(height: 20),
              FinnButton(label: ctaLabel!, onPressed: onPressed),
            ],
          ],
        ),
      ),
    );
  }
}
