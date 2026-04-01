import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FinnLoadingOverlay extends StatelessWidget {
  const FinnLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.overlay,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
