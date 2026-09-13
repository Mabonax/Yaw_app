import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'yaw_brand_assets.dart';

enum YawLogoVariant {
  horizontal,
  horizontalOnDark,
  stacked,
  stackedOnDark,
  icon,
  appIconWithText,
}

class YawLogo extends StatelessWidget {
  const YawLogo({
    super.key,
    this.variant = YawLogoVariant.horizontal,
    this.height = 48,
    this.fit = BoxFit.contain,
  });

  final YawLogoVariant variant;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetFor(variant),
      height: height,
      fit: fit,
      semanticsLabel: 'YAW logo',
    );
  }

  static String _assetFor(YawLogoVariant variant) {
    return switch (variant) {
      YawLogoVariant.horizontal => YawBrandAssets.logoHorizontal,
      YawLogoVariant.horizontalOnDark => YawBrandAssets.logoHorizontalOnDark,
      YawLogoVariant.stacked => YawBrandAssets.logoStacked,
      YawLogoVariant.stackedOnDark => YawBrandAssets.logoStackedOnDark,
      YawLogoVariant.icon => YawBrandAssets.appIcon,
      YawLogoVariant.appIconWithText => YawBrandAssets.appIconWithText,
    };
  }
}
