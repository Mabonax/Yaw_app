import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/branding/yaw_brand_assets.dart';

class AuthSystemUi extends StatelessWidget {
  const AuthSystemUi({
    super.key,
    required this.child,
    this.darkNavigation = false,
  });

  final Widget child;
  final bool darkNavigation;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: darkNavigation
            ? const Color(0xFF001D45)
            : Colors.white,
      ),
      child: child,
    );
  }
}

class AuthScenicBackground extends StatelessWidget {
  const AuthScenicBackground({
    super.key,
    this.alignment = const Alignment(0.16, 0),
  });

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      YawBrandAssets.splashBackground,
      fit: BoxFit.cover,
      alignment: alignment,
    );
  }
}

class AuthNoStretchScroll extends StatelessWidget {
  const AuthNoStretchScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const AuthNoStretchScrollBehavior(),
      child: child,
    );
  }
}

class AuthNoStretchScrollBehavior extends MaterialScrollBehavior {
  const AuthNoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class AuthLightWash extends StatelessWidget {
  const AuthLightWash({super.key, this.bottomBlue = false});

  final bool bottomBlue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.68),
            Colors.white.withValues(alpha: 0.42),
            Colors.white.withValues(alpha: bottomBlue ? 0.8 : 0.96),
            if (bottomBlue) const Color(0xFF005BAE).withValues(alpha: 0.9),
          ],
          stops: bottomBlue ? const [0, 0.36, 0.62, 1] : const [0, 0.42, 1],
        ),
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x22001E3C),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.chevron_left, size: 34),
          color: const Color(0xFF0A73DD),
          tooltip: 'Back',
        ),
      ),
    );
  }
}

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: Color(0xFF0A2D59),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        errorMaxLines: 3,
        hintStyle: const TextStyle(
          color: Color(0xFF788CAD),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF0A3D82), size: 28),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: YawSpacing.xl,
          vertical: 22,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFC8DCF2), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF0A82F0), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: YawColors.critical, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: YawColors.critical, width: 1.6),
        ),
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 70,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF27C8EF), Color(0xFF0567E8)],
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330071D9),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
            padding: const EdgeInsets.symmetric(horizontal: YawSpacing.xxl),
          ),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: YawSpacing.sm),
                    const Icon(Icons.arrow_forward, size: 34),
                  ],
                ),
        ),
      ),
    );
  }
}

class AuthDividerText extends StatelessWidget {
  const AuthDividerText({
    super.key,
    required this.text,
    this.color = const Color(0xFF7486A3),
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color.withValues(alpha: 0.28))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: YawSpacing.xl),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: color.withValues(alpha: 0.28))),
      ],
    );
  }
}

class AuthBlueCorner extends StatelessWidget {
  const AuthBlueCorner({super.key, this.flip = false});

  final bool flip;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AuthCornerPainter(flip: flip));
  }
}

class _AuthCornerPainter extends CustomPainter {
  const _AuthCornerPainter({required this.flip});

  final bool flip;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF28C9EF), Color(0xFF0063D8)],
      ).createShader(Offset.zero & size);
    final softPaint = Paint()
      ..color = const Color(0xFF7DD7FF).withValues(alpha: 0.38);
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..strokeWidth = 1.2;

    final path = Path();
    if (flip) {
      path
        ..moveTo(size.width, size.height * 0.62)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * 0.68, size.height)
        ..close();
      final slash = Path()
        ..moveTo(size.width * 0.85, size.height)
        ..lineTo(size.width, size.height * 0.82)
        ..lineTo(size.width, size.height * 0.9)
        ..lineTo(size.width * 0.92, size.height)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(slash, softPaint);
      canvas.drawLine(
        Offset(size.width * 0.74, size.height),
        Offset(size.width, size.height * 0.68),
        linePaint,
      );
    } else {
      path
        ..moveTo(0, size.height * 0.74)
        ..lineTo(size.width * 0.24, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuthCornerPainter oldDelegate) =>
      oldDelegate.flip != flip;
}
