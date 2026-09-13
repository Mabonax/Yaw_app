import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/branding/yaw_logo.dart';
import '../../../core/widgets/yaw_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
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
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(YawSpacing.page),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - YawSpacing.page * 2,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: ListenableBuilder(
                      listenable: widget.authController,
                      builder: (context, _) {
                        final state = widget.authController.state;

                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Center(
                                child: YawLogo(
                                  variant: YawLogoVariant.horizontal,
                                  height: 72,
                                ),
                              ),
                              const SizedBox(height: YawSpacing.xxl),
                              Text(
                                'Sign in to YAW',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: YawSpacing.sm),
                              Text(
                                'Access pilot, aircraft, mission, and compliance operations.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: YawColors.textMuted),
                              ),
                              const SizedBox(height: YawSpacing.xxl),
                              if (state.errorMessage != null) ...[
                                YawErrorState(
                                  title: 'Sign-in unavailable',
                                  message: state.errorMessage!,
                                ),
                                const SizedBox(height: YawSpacing.lg),
                              ],
                              YawTextField(
                                controller: _emailController,
                                label: 'Email address',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: YawSpacing.lg),
                              YawTextField(
                                controller: _passwordController,
                                label: 'Password',
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: YawSpacing.xl),
                              YawPrimaryButton(
                                label: 'Sign in',
                                icon: Icons.login,
                                isLoading: state.isSubmitting,
                                onPressed: state.isSubmitting ? null : _submit,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required.';
    }
    if (!email.contains('@')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Password is required.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}
