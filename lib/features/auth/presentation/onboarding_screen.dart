import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/branding/yaw_brand_assets.dart';
import '../../../core/branding/yaw_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF005BAE),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF8FF),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _OnboardingBackground(),
            const _LightWash(),
            const Positioned.fill(child: IgnorePointer(child: _BrandPanels())),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 760;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            YawSpacing.xxl,
                            compact ? YawSpacing.xl : 62,
                            YawSpacing.xxl,
                            YawSpacing.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _HeroCopy(compact: compact)),
                                  SizedBox(width: compact ? YawSpacing.md : 18),
                                  YawLogo(
                                    variant: YawLogoVariant.full,
                                    height: compact ? 92 : 124,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                              SizedBox(height: compact ? YawSpacing.xl : 42),
                              const _FeatureList(),
                              const Spacer(),
                              _GetStartedButton(onPressed: onSignIn),
                              const SizedBox(height: YawSpacing.xl),
                              _SignInPrompt(onPressed: onSignIn),
                              const SizedBox(height: YawSpacing.xxl),
                              const _PageDots(),
                              const SizedBox(height: YawSpacing.md),
                            ],
                          ),
                        ),
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

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      YawBrandAssets.onboardingBackground,
      fit: BoxFit.cover,
      alignment: const Alignment(0.24, 0),
    );
  }
}

class _LightWash extends StatelessWidget {
  const _LightWash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.72),
            Colors.white.withValues(alpha: 0.16),
            const Color(0xFF003B78).withValues(alpha: 0.86),
          ],
          stops: const [0, 0.4, 0.62, 1],
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
      color: const Color(0xFF082D59),
      fontWeight: FontWeight.w800,
      height: 1.02,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: compact ? 84 : 132),
        Text('Fly with\nConfidence', style: titleStyle),
        const SizedBox(height: YawSpacing.xl),
        Text(
          'Plan smarter. Operate safely.\nStay compliant.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF627087),
            fontWeight: FontWeight.w400,
            height: 1.22,
          ),
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FeatureItem(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Plan',
          body: 'Prepare and assess\nyour missions.',
        ),
        SizedBox(height: YawSpacing.lg),
        _FeatureItem(
          icon: Icons.near_me_outlined,
          title: 'Fly',
          body: 'Operate with real-time\ninsights.',
        ),
        SizedBox(height: YawSpacing.lg),
        _FeatureItem(
          icon: Icons.verified_user_outlined,
          title: 'Comply',
          body: 'Keep your operations\naudit-ready.',
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFD9F0FF).withValues(alpha: 0.88),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF083B73), size: 30),
        ),
        const SizedBox(width: YawSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF082D59),
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: YawSpacing.xs),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4F5D72),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 78),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(39),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33001F3E),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0478E7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(39),
            ),
            padding: const EdgeInsets.symmetric(horizontal: YawSpacing.xxl),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Get Started',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0478E7),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: YawSpacing.sm),
              const Icon(Icons.arrow_forward, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF44B7FF),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'Sign In',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF44B7FF),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(true),
        const SizedBox(width: YawSpacing.md),
        _dot(false),
        const SizedBox(width: YawSpacing.md),
        _dot(false),
      ],
    );
  }

  Widget _dot(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: selected ? 14 : 13,
      height: selected ? 14 : 13,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.24),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BrandPanels extends StatelessWidget {
  const _BrandPanels();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BrandPanelsPainter());
  }
}

class _BrandPanelsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final slashPaint = Paint()
      ..color = const Color(0xFF0076D9).withValues(alpha: 0.22);
    final brightSlashPaint = Paint()
      ..color = const Color(0xFF54BFFF).withValues(alpha: 0.28);
    final lowerPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00214A).withValues(alpha: 0.92),
              const Color(0xFF0075D9).withValues(alpha: 0.78),
            ],
          ).createShader(
            Rect.fromLTWH(0, size.height * 0.54, size.width, size.height),
          );
    final linePaint = Paint()
      ..color = const Color(0xFF54BFFF).withValues(alpha: 0.56)
      ..strokeWidth = 1.4;

    final topSlash = Path()
      ..moveTo(size.width * 0.78, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.42)
      ..lineTo(size.width * 0.64, size.height * 0.28)
      ..close();
    canvas.drawPath(topSlash, slashPaint);

    final brightSlash = Path()
      ..moveTo(size.width, size.height * 0.2)
      ..lineTo(size.width, size.height * 0.24)
      ..lineTo(size.width * 0.54, size.height * 0.63)
      ..lineTo(size.width * 0.5, size.height * 0.61)
      ..close();
    canvas.drawPath(brightSlash, brightSlashPaint);

    final lower = Path()
      ..moveTo(0, size.height * 0.54)
      ..lineTo(size.width * 0.6, size.height * 0.78)
      ..lineTo(size.width, size.height * 0.44)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(lower, lowerPaint);

    final leftStripe = Path()
      ..moveTo(0, size.height * 0.54)
      ..lineTo(size.width * 0.56, size.height * 0.78)
      ..lineTo(size.width * 0.66, size.height * 0.78)
      ..lineTo(0, size.height * 0.49)
      ..close();
    canvas.drawPath(leftStripe, brightSlashPaint);

    canvas.drawLine(
      Offset(0, size.height * 0.61),
      Offset(size.width * 0.29, size.height * 0.49),
      linePaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.97),
      Offset(size.width * 0.72, size.height * 0.48),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
