import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/branding/yaw_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YawLogo(variant: YawLogoVariant.appIconWithText, height: 92),
              SizedBox(height: YawSpacing.lg),
              Text('Preparing aviation workspace'),
            ],
          ),
        ),
      ),
    );
  }
}
