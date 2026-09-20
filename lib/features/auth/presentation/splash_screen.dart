import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/branding/yaw_brand_assets.dart';
import '../../../core/branding/yaw_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF011326),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF011326),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _SplashBackground(),
            const _SkyWash(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 760;
                  final logoHeight = compact ? 230.0 : 300.0;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: YawSpacing.xl,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: compact ? YawSpacing.lg : 74),
                              YawLogo(
                                variant: YawLogoVariant.fullOnDark,
                                height: logoHeight,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: YawSpacing.lg),
                              Text(
                                'Smarter operations\nfor a higher tomorrow.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.86,
                                      ),
                                      fontWeight: FontWeight.w300,
                                      height: 1.45,
                                    ),
                              ),
                              const Spacer(),
                              const _InitialisingIndicator(),
                              SizedBox(height: compact ? 70 : 108),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Positioned.fill(child: IgnorePointer(child: _BottomPanels())),
          ],
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      YawBrandAssets.splashBackground,
      fit: BoxFit.cover,
      alignment: const Alignment(0.12, 0),
    );
  }
}

class _SkyWash extends StatelessWidget {
  const _SkyWash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF001B45).withValues(alpha: 0.54),
            const Color(0xFF004F9E).withValues(alpha: 0.18),
            const Color(0xFF001326).withValues(alpha: 0.58),
          ],
          stops: const [0, 0.48, 1],
        ),
      ),
      child: CustomPaint(painter: _DiagonalLightPainter()),
    );
  }
}

class _InitialisingIndicator extends StatelessWidget {
  const _InitialisingIndicator();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Initialising',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF18C7FF)),
              backgroundColor: Colors.white.withValues(alpha: 0.32),
            ),
          ),
          const SizedBox(height: YawSpacing.lg),
          Text(
            'INITIALISING',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPanels extends StatelessWidget {
  const _BottomPanels();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BottomPanelsPainter(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 44),
          child: Text(
            'VARIOUS MEDIA TECHNOLOGIES',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.46),
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagonalLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(0, size.height * 0.37)
      ..lineTo(size.width * 0.86, 0)
      ..lineTo(size.width * 0.43, 0)
      ..lineTo(0, size.height * 0.34)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomPanelsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height * 0.84;
    final deepPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF001327).withValues(alpha: 0.86),
          const Color(0xFF004A8B).withValues(alpha: 0.82),
          const Color(0xFF000B18).withValues(alpha: 0.94),
        ],
      ).createShader(Rect.fromLTWH(0, baseY, size.width, size.height - baseY));
    final bluePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF002245).withValues(alpha: 0.9),
          const Color(0xFF0B78CF).withValues(alpha: 0.84),
        ],
      ).createShader(Rect.fromLTWH(0, baseY, size.width, size.height - baseY));
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.34)
      ..strokeWidth = 1;

    final back = Path()
      ..moveTo(0, baseY)
      ..lineTo(size.width * 0.52, baseY + 68)
      ..lineTo(size.width, baseY - 54)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final front = Path()
      ..moveTo(0, baseY + 84)
      ..lineTo(size.width * 0.56, baseY + 58)
      ..lineTo(size.width, baseY + 122)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(back, deepPaint);
    canvas.drawPath(front, bluePaint);
    canvas.drawLine(
      Offset(0, baseY),
      Offset(size.width * 0.52, baseY + 68),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.52, baseY + 68),
      Offset(size.width, baseY - 54),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
