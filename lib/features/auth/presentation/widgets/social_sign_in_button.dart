import 'package:flutter/material.dart';

import '../../../../shared/widgets/finn_button.dart';

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FinnButton(
      label: 'Continue with Google',
      onPressed: onPressed,
      isLoading: isLoading,
      variant: FinnButtonVariant.secondary,
      icon: Icons.g_mobiledata_rounded,
    );
  }
}
