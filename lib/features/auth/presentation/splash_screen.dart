import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';

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
              Icon(
                Icons.flight_takeoff,
                color: YawColors.aviationBlue,
                size: 56,
              ),
              SizedBox(height: YawSpacing.lg),
              Text(
                'YAW',
                style: TextStyle(
                  color: YawColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: YawSpacing.sm),
              Text('Preparing aviation workspace'),
            ],
          ),
        ),
      ),
    );
  }
}
