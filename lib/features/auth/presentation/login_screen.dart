import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/branding/yaw_logo.dart';
import '../../../core/widgets/yaw_widgets.dart';
import 'auth_visuals.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.authController,
    this.onCreateAccount,
  });

  final AuthController authController;
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return AuthSystemUi(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Scenic YAW authentication background.
            const AuthScenicBackground(alignment: Alignment(0.12, -0.12)),

            // Light overlay for readability.
            const AuthLightWash(),

            // Decorative blue corner.
            const Positioned.fill(
              child: IgnorePointer(child: AuthBlueCorner(flip: true)),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 760;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: YawSpacing.xl),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: compact ? YawSpacing.lg : 42),

                          // YAW logo.
                          Center(
                            child: YawLogo(
                              variant: YawLogoVariant.full,
                              height: compact ? 130 : 176,
                            ),
                          ),

                          // Welcome copy.
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              YawSpacing.xxl,
                              YawSpacing.lg,
                              YawSpacing.xxl,
                              0,
                            ),
                            child: _WelcomeCopy(compact: compact),
                          ),

                          SizedBox(height: compact ? YawSpacing.lg : 60),

                          // Authentication panel.
                          _LoginPanel(
                            authController: authController,
                            onCreateAccount: onCreateAccount,
                          ),
                        ],
                      ),
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

class _WelcomeCopy extends StatelessWidget {
  const _WelcomeCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: compact ? YawSpacing.lg : 46),
        Text(
          'Welcome\nBack',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: const Color(0xFF082D59),
            fontWeight: FontWeight.w900,
            height: 1.02,
          ),
        ),
        const SizedBox(height: YawSpacing.lg),
        Text(
          'Sign in to continue\nyour operations.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF445775),
            fontWeight: FontWeight.w400,
            height: 1.18,
          ),
        ),
      ],
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({required this.authController, this.onCreateAccount});

  final AuthController authController;
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FCFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(46)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F001E3C),
            blurRadius: 28,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          YawSpacing.xxl,
          YawSpacing.xl,
          YawSpacing.xxl,
          56,
        ),
        child: ListenableBuilder(
          listenable: authController,
          builder: (context, _) {
            final state = authController.state;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Panel handle.
                Center(
                  child: Container(
                    width: 68,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3DAE4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                const SizedBox(height: YawSpacing.xxl),

                // Authentication heading.
                Text(
                  'Sign in to YAW',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF082D59),
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: YawSpacing.sm),

                // Authentication description.
                Text(
                  'Access your aviation operations, missions and '
                  'compliance workspace.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF61728F),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: YawSpacing.xxl),

                // Authentication errors from AuthController.
                if (state.errorMessage != null) ...[
                  YawErrorState(
                    title: 'Sign-in unavailable',
                    message: state.errorMessage!,
                  ),
                  const SizedBox(height: YawSpacing.lg),
                ],

                // ---------------------------------------------------------
                // PRIMARY LOGIN ACTION
                // ---------------------------------------------------------
                //
                // WorkOS is the authentication provider configured by the
                // YAW backend.
                //
                // There is deliberately NO separate "Continue with WorkOS"
                // button and NO email/password login form.
                //
                // User sees:
                //
                //      Sign In
                //
                // Internally:
                //
                //      Sign In
                //          ↓
                //      loginWithWorkos()
                //          ↓
                //      WorkOS
                //          ↓
                //      YAW backend callback
                //
                // ---------------------------------------------------------
                AuthGradientButton(
                  label: 'Sign In',
                  isLoading: state.isSubmitting,
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          authController.loginWithWorkos();
                        },
                ),

                const SizedBox(height: YawSpacing.lg),

                // Security message.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 17,
                      color: Color(0xFF7A899F),
                    ),
                    const SizedBox(width: YawSpacing.sm),
                    Flexible(
                      child: Text(
                        'Secure authentication',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF7A899F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                // Only show account creation section when the application
                // actually supplied an account creation callback.
                if (onCreateAccount != null) ...[
                  const SizedBox(height: YawSpacing.xxl),

                  const AuthDividerText(text: 'NEW TO YAW?'),

                  const SizedBox(height: YawSpacing.xl),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: const Color(0xFF5D6D86)),
                      ),
                      TextButton(
                        onPressed: state.isSubmitting ? null : onCreateAccount,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Create one',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF0578E9),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: YawSpacing.xxl),

                // Footer.
                Text(
                  'By continuing, you agree to YAW\'s terms of use '
                  'and privacy policy.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8B98AA),
                    height: 1.4,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
