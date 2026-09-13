import 'package:flutter/material.dart';

class YawColors {
  const YawColors._();

  static const aviationBlue = Color(0xFF075DA8);
  static const aviationBlueDark = Color(0xFF063D72);
  static const aviationBlueSoft = Color(0xFFEAF4FF);
  static const navy = Color(0xFF102033);
  static const charcoal = Color(0xFF243244);
  static const textMuted = Color(0xFF657487);
  static const surface = Colors.white;
  static const background = Color(0xFFF6F9FC);
  static const border = Color(0xFFDDE6F0);
  static const healthy = Color(0xFF23824D);
  static const healthySoft = Color(0xFFE8F6EE);
  static const warning = Color(0xFFB7791F);
  static const warningSoft = Color(0xFFFFF4DC);
  static const critical = Color(0xFFB42318);
  static const criticalSoft = Color(0xFFFDE8E6);
  static const infoSoft = Color(0xFFEAF4FF);
}

class YawSpacing {
  const YawSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const page = 20.0;
  static const card = 18.0;
}

class YawRadius {
  const YawRadius._();

  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
}

class YawElevation {
  const YawElevation._();

  static const card = [
    BoxShadow(color: Color(0x140A2A43), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

class YawSizing {
  const YawSizing._();

  static const iconSm = 18.0;
  static const iconMd = 22.0;
  static const iconLg = 28.0;
  static const buttonHeight = 48.0;
  static const fieldHeight = 52.0;
  static const minTouchTarget = 48.0;
}
