import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/branding/yaw_logo.dart';
import '../../../core/widgets/yaw_widgets.dart';
import 'auth_visuals.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
    required this.authController,
    required this.onBack,
    required this.onSignIn,
  });

  final AuthController authController;
  final VoidCallback onBack;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return AuthSystemUi(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AuthScenicBackground(alignment: Alignment(0.08, -0.06)),
            const AuthLightWash(),
            SafeArea(
              child: ListenableBuilder(
                listenable: authController,
                builder: (context, _) {
                  final state = authController.state;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(YawSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AuthBackButton(onPressed: onBack),
                        ),
                        const SizedBox(height: YawSpacing.lg),
                        const Center(
                          child: YawLogo(
                            variant: YawLogoVariant.full,
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: YawSpacing.xxl),
                        Text(
                          'Create Your Account',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: YawSpacing.lg),
                        const Text(
                          'Create your YAW account securely with WorkOS. You can use the same account on the web and in this app.',
                        ),
                        const SizedBox(height: YawSpacing.xxl),
                        if (state.errorMessage != null) ...[
                          YawErrorState(
                            title: 'Registration unavailable',
                            message: state.errorMessage!,
                          ),
                          const SizedBox(height: YawSpacing.lg),
                        ],
                        AuthGradientButton(
                          label: 'Create Account with WorkOS',
                          isLoading: state.isSubmitting,
                          onPressed: () =>
                              authController.loginWithWorkos(signUp: true),
                        ),
                        const SizedBox(height: YawSpacing.lg),
                        const Text(
                          'Your browser will open for registration and email verification. You will return here when finished.',
                        ),
                        const SizedBox(height: YawSpacing.xxl),
                        TextButton(
                          onPressed: state.isSubmitting ? null : onSignIn,
                          child: const Text('Already have an account? Sign in'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
