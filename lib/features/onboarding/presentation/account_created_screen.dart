import 'package:flutter/material.dart';

import 'setup_widgets.dart';

/// Shown only after confirmed registration, or by the isolated design preview.
class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({
    super.key,
    required this.onLogin,
    required this.onDashboard,
  });
  final VoidCallback onLogin, onDashboard;
  @override
  Widget build(BuildContext context) => SetupFrame(
    child: Column(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).width.clamp(320.0, 500.0) * .98,
          child: Stack(
            children: [
              const Positioned.fill(child: SetupScenery()),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 12,
                left: 0,
                right: 0,
                child: const Center(child: SetupLogo()),
              ),
              Positioned(
                left: 28,
                bottom: 100,
                child: Text(
                  'HIGHER\nSTANDARDS\nSAFER SKIES',
                  style: setupText(
                    6.5,
                    color: Colors.white,
                  ).copyWith(letterSpacing: 1.8, height: 1.7),
                ),
              ),
              Positioned(
                right: 28,
                bottom: 100,
                child: Text(
                  'PEOPLE\nSAFER SKIES\nBRIGHTER\nPOSSIBILITIES',
                  style: setupText(
                    6.5,
                    color: Colors.white,
                  ).copyWith(letterSpacing: 1.3, height: 1.7),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 6,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .55),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF35B5FB).withValues(alpha: .20),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF16BCEB), Color(0xFF006BF0)],
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 43,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Account Created!',
                textAlign: TextAlign.center,
                style: setupText(
                  28,
                  weight: FontWeight.w600,
                ).copyWith(letterSpacing: -.8),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome to YAW. Your account has been\ncreated successfully.',
                textAlign: TextAlign.center,
                style: setupText(12, color: setupMuted),
              ),
              const SizedBox(height: 15),
              SetupCard(
                child: Column(
                  children: [
                    _row(
                      Icons.mail_outline,
                      'Verification Email Sent',
                      'We’ve sent a verification link to your email address.\nPlease check your inbox (and spam folder).',
                    ),
                    const SizedBox(height: 14),
                    _row(
                      Icons.person_outline,
                      'Profile Ready',
                      'Your pilot profile is saved and ready to use.',
                    ),
                    const SizedBox(height: 14),
                    _row(
                      Icons.flight_outlined,
                      'Start Your Journey',
                      'Log in to access your dashboard and start planning\nand managing your operations.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              SetupButton(label: 'Continue to Login', onPressed: onLogin),
              const SizedBox(height: 8),
              SetupButton(
                label: 'Go to Dashboard',
                onPressed: onDashboard,
                outlined: true,
                icon: Icons.grid_view_outlined,
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'SAFER SKIES. BRIGHTER POSSIBILITIES.',
                      style: setupText(
                        6,
                        color: setupMuted,
                      ).copyWith(letterSpacing: 1),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 45),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _row(IconData icon, String title, String subtitle) => Row(
    children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFEBF2FA),
        child: icon == Icons.flight_outlined
            ? const DroneIcon()
            : Icon(icon, size: 23, color: setupNavy),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: setupText(11, weight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: setupText(8.5, color: setupMuted)),
          ],
        ),
      ),
    ],
  );
}
