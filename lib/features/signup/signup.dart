import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_text_input.dart';
import 'package:expense_tracker/features/auth/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/widgets/auth_scaffold.dart';
import 'package:expense_tracker/features/login/login.dart';
import 'package:expense_tracker/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submitSignup(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      SignupSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(AuthServices()),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthFailure) {
            showCommonSnackBar(context, state.message, isError: true);
          }
          if (state is AuthSuccess) {
            showCommonSnackBar(context, state.message);
          }
        },
        builder: (BuildContext context, AuthState state) {
          final bool isLoading = state is AuthLoading;
          return AuthScaffold(
            title: 'Create Account',
            subtitle: 'Track your spending with confidence.',
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppTextInput(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextInput(
                    controller: _passwordController,
                    obscureText: true,
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextInput(
                    controller: _confirmController,
                    obscureText: true,
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    validator: (String? value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppPrimaryButton(
                    onPressed: isLoading ? null : () => _submitSignup(context),
                    label: isLoading ? 'Please wait...' : 'Sign Up',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => context.read<AuthBloc>().add(
                            const GoogleSignInRequested(
                              source: AuthFlowType.signup,
                            ),
                          ),
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
