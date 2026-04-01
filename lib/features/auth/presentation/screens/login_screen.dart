import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/widgets/finn_button.dart';
import '../../../../shared/widgets/finn_loading_overlay.dart';
import '../../../../shared/widgets/finn_snackbar.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/social_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@finn.app');
  final _passwordController = TextEditingController(text: 'google');

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome back')),
      body: FinnLoadingOverlay(
        isLoading: isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign in to keep your money story in one place.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  AuthFormField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return 'Password should be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FinnButton(
                    label: 'Sign in',
                    onPressed: isLoading ? null : _signIn,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 12),
                  SocialSignInButton(
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _googleSignIn,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('Create account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final failure = await ref
        .read(authActionProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (failure != null) {
      showFinnSnackBar(context, message: failure.message);
      return;
    }
    context.go(AppRoutes.home);
  }

  Future<void> _googleSignIn() async {
    final currency = ref.read(selectedCurrencyProvider);
    final failure = await ref
        .read(authActionProvider.notifier)
        .signInWithGoogle(currency: currency);
    if (!mounted) return;
    if (failure != null) {
      showFinnSnackBar(context, message: failure.message);
      return;
    }
    context.go(AppRoutes.home);
  }
}
