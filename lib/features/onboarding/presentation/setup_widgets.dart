import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/branding/yaw_brand_assets.dart';

const setupNavy = Color(0xFF10345A);
const setupMuted = Color(0xFF7B879D);
const setupBlue = Color(0xFF0088F5);
const setupBackground = Color(0xFFF8FCFF);
TextStyle setupText(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = setupNavy,
}) => TextStyle(
  fontFamily: 'Poppins',
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: 1.25,
);
ThemeData setupTheme(BuildContext context) => Theme.of(context).copyWith(
  textTheme: Theme.of(context).textTheme.apply(
    fontFamily: 'Poppins',
    bodyColor: setupNavy,
    displayColor: setupNavy,
  ),
  scaffoldBackgroundColor: setupBackground,
);

class SetupFrame extends StatelessWidget {
  const SetupFrame({super.key, required this.child, this.cornerLeft = false});
  final Widget child;
  final bool cornerLeft;
  @override
  Widget build(BuildContext context) => Theme(
    data: setupTheme(context),
    child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: setupBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: setupBackground,
        body: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: SetupCorner(left: cornerLeft)),
                ),
              ),
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: math.max(
                          MediaQuery.paddingOf(context).bottom,
                          18,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SetupScenery extends StatelessWidget {
  const SetupScenery({super.key, this.pilot = false, this.fade = true});
  final bool pilot;
  final bool fade;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        pilot
            ? YawBrandAssets.roleBackground
            : 'assets/screens/mountain_lake.png',
        fit: BoxFit.cover,
        alignment: pilot ? const Alignment(0, -.15) : const Alignment(0, -.45),
        excludeFromSemantics: true,
      ),
      if (fade)
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                setupBackground,
                setupBackground,
              ],
              stops: pilot ? [0, .48, .78, 1] : [0, .65, .99, 1],
            ),
          ),
        ),
    ],
  );
}

class SetupHeader extends StatelessWidget {
  const SetupHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.pilot = false,
    this.height = 280,
  });
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final bool pilot;
  final double height;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width.clamp(320.0, 500.0);
    final artHeight = height * width / 390;
    final safeTop = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: artHeight + safeTop,
      child: Stack(
        children: [
          Positioned.fill(child: SetupScenery(pilot: pilot)),
          Positioned(
            top: safeTop + 14,
            left: 18,
            child: Material(
              color: Colors.white.withValues(alpha: .95),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: onBack,
                tooltip: 'Back',
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF5A9BBF),
                  size: 25,
                ),
              ),
            ),
          ),
          Positioned(
            top: safeTop + 2,
            left: 0,
            right: 0,
            child: const Center(child: SetupLogo()),
          ),
          Positioned(
            top: pilot ? null : safeTop + 112,
            bottom: pilot ? 10 : null,
            left: 28,
            right: pilot ? 40 : 158,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: pilot
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: .55),
                          blurRadius: 32,
                          spreadRadius: 10,
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: setupText(
                      pilot ? 28 : 25,
                      weight: FontWeight.w600,
                    ).copyWith(height: 1.03, letterSpacing: -.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: setupText(11.5, color: const Color(0xFF596B82)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SetupStepper extends StatelessWidget {
  const SetupStepper({super.key, required this.step, this.onStep});
  final int step;
  final ValueChanged<int>? onStep;
  static const labels = [
    'Personal\nDetails',
    'Aircraft\nDetails',
    'Certifications',
    'Review',
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (i < 3)
                  Positioned(
                    left: 31,
                    right: -14,
                    top: 13,
                    child: Container(height: 1, color: const Color(0xFFD9E3EE)),
                  ),
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: i < step && onStep != null ? () => onStep!(i) : null,
                    child: Column(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= step ? setupBlue : Colors.white,
                            border: Border.all(
                              color: i <= step
                                  ? setupBlue
                                  : const Color(0xFFE1E8EF),
                            ),
                          ),
                          child: i < step
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: setupText(
                                    11,
                                    weight: FontWeight.w600,
                                    color: i == step ? Colors.white : setupNavy,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          labels[i],
                          textAlign: TextAlign.center,
                          style: setupText(
                            8,
                            color: i == step ? setupNavy : setupMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class SetupButton extends StatelessWidget {
  const SetupButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon = Icons.arrow_forward,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 43),
    decoration: BoxDecoration(
      gradient: outlined
          ? null
          : const LinearGradient(
              colors: [Color(0xFF19C5EA), Color(0xFF0062E6)],
            ),
      borderRadius: BorderRadius.circular(28),
      border: outlined ? Border.all(color: const Color(0xFF35B9E1)) : null,
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        foregroundColor: outlined ? setupBlue : Colors.white,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          const SizedBox(width: 21),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: setupText(
                11.5,
                weight: FontWeight.w600,
                color: outlined ? setupBlue : Colors.white,
              ),
            ),
          ),
          Icon(icon, size: 20),
        ],
      ),
    ),
  );
}

class SetupSectionTitle extends StatelessWidget {
  const SetupSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: setupText(16, weight: FontWeight.w600)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: setupText(10, color: setupMuted)),
              ],
            ],
          ),
        ),
        ?action,
      ],
    ),
  );
}

InputDecoration setupInputDecoration(
  String hint, {
  IconData? icon,
  Widget? suffix,
}) => InputDecoration(
  hintText: hint,
  hintStyle: setupText(10.5, color: const Color(0xFF97A2B4)),
  errorStyle: setupText(10, color: Colors.red.shade700),
  errorMaxLines: 2,
  prefixIcon: icon == null ? null : Icon(icon, size: 18, color: setupNavy),
  suffixIcon: suffix,
  suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 26),
  prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 42),
  isDense: true,
  filled: true,
  fillColor: Colors.white.withValues(alpha: .55),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: setupBlue),
  ),
);

class SetupCard extends StatelessWidget {
  const SetupCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.color = const Color(0x66FFFFFF),
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: const Color(0xFFE7EDF3)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: child,
  );
}

class SetupCorner extends CustomPainter {
  const SetupCorner({this.left = false});
  final bool left;
  @override
  void paint(Canvas canvas, Size size) {
    if (left) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final w = size.width, h = size.height;
    for (final (distance, color) in [
      (115.0, const Color(0xFFC0E6FA)),
      (82.0, const Color(0xFF54B9EA)),
      (65.0, const Color(0xFF0964C9)),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(w, h - distance)
          ..lineTo(w, h)
          ..lineTo(w - distance, h)
          ..close(),
        Paint()..color = color,
      );
    }
    canvas.drawLine(
      Offset(w - 62, h),
      Offset(w, h - 70),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(SetupCorner oldDelegate) => oldDelegate.left != left;
}

class DroneIcon extends StatelessWidget {
  const DroneIcon({super.key, this.size = 28, this.color = setupNavy});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size * .68), painter: _DronePainter(color));
}

class _DronePainter extends CustomPainter {
  _DronePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 28);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 9, 8, 7),
        const Radius.circular(2),
      ),
      p,
    );
    for (final x in [7.0, 33.0]) {
      canvas.drawLine(Offset(x, 6), const Offset(20, 13), p);
      canvas.drawLine(Offset(x, 18), const Offset(20, 13), p);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 5), width: 12, height: 2.5),
        p,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 18), width: 12, height: 2.5),
        p,
      );
      canvas.drawLine(Offset(x, 5), Offset(x, 12), p);
    }
    canvas.drawLine(const Offset(16, 15), const Offset(13, 26), p);
    canvas.drawLine(const Offset(24, 15), const Offset(27, 26), p);
    canvas.drawCircle(const Offset(20, 18), 2, p);
  }

  @override
  bool shouldRepaint(_DronePainter oldDelegate) => color != oldDelegate.color;
}

class SetupLogo extends StatelessWidget {
  const SetupLogo({super.key, this.horizontal = false});
  final bool horizontal;
  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: horizontal ? 44 : 84,
      height: horizontal ? 45 : 74,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(0, horizontal ? 8 : 14),
          child: Transform.scale(
            scale: 2.5,
            child: Image.asset(
              YawBrandAssets.appIcon,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'YAW',
          style: setupText(
            horizontal ? 23 : 18,
            weight: FontWeight.w600,
          ).copyWith(height: 1, letterSpacing: -.7),
        ),
        const SizedBox(height: 3),
        Text(
          'PLAN. FLY. COMPLY.',
          style: setupText(
            horizontal ? 5 : 6,
            color: setupNavy,
          ).copyWith(letterSpacing: .4),
        ),
      ],
    );
    return Semantics(
      label: 'YAW. Plan. Fly. Comply.',
      child: horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [mark, const SizedBox(width: 4), text],
            )
          : Column(mainAxisSize: MainAxisSize.min, children: [mark, text]),
    );
  }
}
