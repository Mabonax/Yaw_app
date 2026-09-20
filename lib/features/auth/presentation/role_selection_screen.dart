import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/branding/yaw_brand_assets.dart';
import '../../../core/branding/yaw_logo.dart';
import 'auth_visuals.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key, required this.onContinue});

  final ValueChanged<YawRoleOption> onContinue;

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  YawRoleOption _selected = YawRoleOption.pilot;

  @override
  Widget build(BuildContext context) {
    return AuthSystemUi(
      darkNavigation: true,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _RoleBackground(),
            const _RoleWash(),
            const Positioned.fill(child: IgnorePointer(child: _RoleGeometry())),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact =
                      constraints.maxHeight < 860 || constraints.maxWidth < 450;
                  final topHeight = compact ? 150.0 : 230.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: YawSpacing.sm),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: topHeight,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: YawSpacing.xxl,
                                  top: compact ? 6 : 22,
                                  child: YawLogo(
                                    variant: YawLogoVariant.full,
                                    height: compact ? 96 : 136,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, compact ? -4 : -18),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: YawSpacing.xxl,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _TitleBlock(compact: compact),
                                  SizedBox(
                                    height: compact
                                        ? YawSpacing.md
                                        : YawSpacing.xl,
                                  ),
                                  _RoleGrid(
                                    selected: _selected,
                                    compact: compact,
                                    onSelected: (role) => setState(() {
                                      _selected = role;
                                    }),
                                  ),
                                  SizedBox(
                                    height: compact
                                        ? YawSpacing.md
                                        : YawSpacing.xl,
                                  ),
                                  AuthGradientButton(
                                    label: 'Continue',
                                    height: compact ? 56 : 62,
                                    onPressed: () =>
                                        widget.onContinue(_selected),
                                  ),
                                  SizedBox(
                                    height: compact
                                        ? YawSpacing.md
                                        : YawSpacing.lg,
                                  ),
                                  const Text(
                                    'SAFER SKIES. BRIGHTER POSSIBILITIES.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 1,
                                      color: Color(0xFF7A8AA4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

enum YawRoleOption { pilot, operator, maintenance, regulatory }

extension YawRoleOptionDetails on YawRoleOption {
  String get title {
    return switch (this) {
      YawRoleOption.pilot => 'Pilot',
      YawRoleOption.operator => 'Operator',
      YawRoleOption.maintenance => 'Maintenance',
      YawRoleOption.regulatory => 'Regulatory',
    };
  }

  String get description {
    return switch (this) {
      YawRoleOption.pilot =>
        'Manage your pilot profile,\nlog flights and keep your\ncertifications up to date.',
      YawRoleOption.operator =>
        'Manage your organization,\naircraft, crew and operations.',
      YawRoleOption.maintenance =>
        'Track defects, serviceability\nand maintenance records.',
      YawRoleOption.regulatory =>
        'Access forms, compliance\ntools and regulatory resources.',
    };
  }

  IconData get icon {
    return switch (this) {
      YawRoleOption.pilot => Icons.badge_outlined,
      YawRoleOption.operator => Icons.apartment_outlined,
      YawRoleOption.maintenance => Icons.build_outlined,
      YawRoleOption.regulatory => Icons.fact_check_outlined,
    };
  }
}

class _RoleBackground extends StatelessWidget {
  const _RoleBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      YawBrandAssets.roleBackground,
      fit: BoxFit.cover,
      alignment: const Alignment(0.18, -0.44),
    );
  }
}

class _RoleWash extends StatelessWidget {
  const _RoleWash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.02),
            Colors.white.withValues(alpha: 0.18),
            const Color(0xFFF7FCFF).withValues(alpha: 0.94),
            Colors.white,
          ],
          stops: const [0, 0.34, 0.47, 1],
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF087BEE),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(height: compact ? YawSpacing.md : YawSpacing.xl),
        Text(
          'Choose Your Role',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF082D59),
            fontWeight: FontWeight.w900,
            height: 1.02,
          ),
        ),
        SizedBox(height: compact ? YawSpacing.sm : YawSpacing.md),
        Text(
          'Get a personalized experience\nbased on your role.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF687896),
            fontWeight: FontWeight.w500,
            height: 1.16,
          ),
        ),
      ],
    );
  }
}

class _RoleGrid extends StatelessWidget {
  const _RoleGrid({
    required this.selected,
    required this.compact,
    required this.onSelected,
  });

  final YawRoleOption selected;
  final bool compact;
  final ValueChanged<YawRoleOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0)
            SizedBox(height: compact ? YawSpacing.md : YawSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < 2; column++) ...[
                  if (column > 0)
                    SizedBox(width: compact ? YawSpacing.md : YawSpacing.lg),
                  Expanded(
                    child: _RoleCard(
                      role: YawRoleOption.values[row * 2 + column],
                      selected:
                          selected == YawRoleOption.values[row * 2 + column],
                      compact: compact,
                      onTap: () =>
                          onSelected(YawRoleOption.values[row * 2 + column]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final YawRoleOption role;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF0981F4)
        : const Color(0xFFDDE8F4);
    final arrowColor = selected
        ? const Color(0xFF087BEE)
        : const Color(0xFFE9F1FA);
    final arrowIconColor = selected ? Colors.white : const Color(0xFF092D5A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(compact ? YawSpacing.md : YawSpacing.lg),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEAF9FF).withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 2 : 1.4),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1F008AE8),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    role.icon,
                    color: const Color(0xFF082D59),
                    size: compact ? 34 : 38,
                  ),
                  const Spacer(),
                  Container(
                    width: compact ? 38 : 42,
                    height: compact ? 38 : 42,
                    decoration: BoxDecoration(
                      color: arrowColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: arrowIconColor,
                      size: compact ? 20 : 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                role.title,
                style:
                    (compact
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                          color: const Color(0xFF082D59),
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
              ),
              SizedBox(height: compact ? YawSpacing.xs : YawSpacing.sm),
              Text(
                role.description,
                style:
                    (compact
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.bodyLarge)
                        ?.copyWith(
                          color: const Color(0xFF6C7B97),
                          fontSize: compact ? 11.5 : 14,
                          height: 1.16,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleGeometry extends StatelessWidget {
  const _RoleGeometry();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RoleGeometryPainter());
  }
}

class _RoleGeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topPaint = Paint()..color = Colors.white.withValues(alpha: 0.16);
    final bottomPaint = Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0xFF28C9EF), Color(0xFF0063D8)],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.83,
              size.width * 0.35,
              size.height * 0.17,
            ),
          );
    final softPaint = Paint()
      ..color = const Color(0xFF9CE5FF).withValues(alpha: 0.44);
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..strokeWidth = 1.2;

    final topSlash = Path()
      ..moveTo(size.width * 0.28, 0)
      ..lineTo(size.width * 0.39, 0)
      ..lineTo(size.width * 0.08, size.height * 0.22)
      ..lineTo(0, size.height * 0.18)
      ..close();
    canvas.drawPath(topSlash, topPaint);

    final bottom = Path()
      ..moveTo(0, size.height * 0.86)
      ..lineTo(size.width * 0.33, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(bottom, bottomPaint);

    final slash = Path()
      ..moveTo(0, size.height * 0.84)
      ..lineTo(size.width * 0.22, size.height)
      ..lineTo(size.width * 0.28, size.height)
      ..lineTo(0, size.height * 0.8)
      ..close();
    canvas.drawPath(slash, softPaint);
    canvas.drawLine(
      Offset(0, size.height * 0.88),
      Offset(size.width * 0.17, size.height * 0.98),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
