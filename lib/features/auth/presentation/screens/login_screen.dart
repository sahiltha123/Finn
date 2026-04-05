import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            child: FormBuilder(
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
                    name: 'email',
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Email is required',
                      ),
                      FormBuilderValidators.email(
                        errorText: 'Enter a valid email',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    name: 'password',
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Password is required',
                      ),
                      FormBuilderValidators.minLength(
                        4,
                        errorText: 'Password should be at least 4 characters',
                      ),
                    ]),
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
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;
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
