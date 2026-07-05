import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_text_input.dart';
import 'package:expense_tracker/features/auth/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/widgets/auth_scaffold.dart';
import 'package:expense_tracker/features/expenses/expenses_page.dart';
import 'package:expense_tracker/features/signup/signup.dart';
import 'package:expense_tracker/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      LoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<void>(builder: (_) => const ExpensesPage()),
              (Route<dynamic> route) => false,
            );
          }
        },
        builder: (BuildContext context, AuthState state) {
          final bool isLoading = state is AuthLoading;
          return AuthScaffold(
            title: 'Welcome Back',
            subtitle: 'Login to continue managing your expenses.',
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppPrimaryButton(
                    onPressed: isLoading ? null : () => _submitLogin(context),
                    label: isLoading ? 'Please wait...' : 'Login',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => context.read<AuthBloc>().add(
                            const GoogleSignInRequested(
                              source: AuthFlowType.login,
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
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                    child: const Text('Don\'t have an account? Sign Up'),
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
