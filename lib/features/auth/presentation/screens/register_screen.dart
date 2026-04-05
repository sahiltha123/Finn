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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionProvider);
    final isLoading = authState.isLoading;
    final currency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create your Finn account')),
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
                    'You are setting up Finn in ${currency.code}. You can change this later in profile.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  AuthFormField(
                    name: 'name',
                    controller: _nameController,
                    label: 'Full name',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Name is required',
                      ),
                      FormBuilderValidators.minLength(
                        3,
                        errorText: 'Enter your name',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
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
                        errorText: 'Use at least 4 characters',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    name: 'confirm_password',
                    controller: _confirmPasswordController,
                    label: 'Confirm password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FinnButton(
                    label: 'Create account',
                    onPressed: isLoading ? null : _register,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Already have an account? Sign in'),
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

  Future<void> _register() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;
    final currency = ref.read(selectedCurrencyProvider);
    final failure = await ref
        .read(authActionProvider.notifier)
        .signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          currency: currency,
        );
    if (!mounted) return;
    if (failure != null) {
      showFinnSnackBar(context, message: failure.message);
      return;
    }
    context.go(AppRoutes.home);
  }
}
