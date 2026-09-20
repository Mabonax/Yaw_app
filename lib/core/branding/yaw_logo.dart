import 'package:flutter/widgets.dart';

import 'yaw_brand_assets.dart';

enum YawLogoVariant {
  full,
  fullOnDark,
  horizontal,
  horizontalOnDark,
  stacked,
  stackedOnDark,
  icon,
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
    return Image.asset(
      _assetFor(variant),
      height: height,
      fit: fit,
      semanticLabel: 'YAW logo',
    );
  }

  static String _assetFor(YawLogoVariant variant) {
    return switch (variant) {
      YawLogoVariant.full => YawBrandAssets.logoFull,
      YawLogoVariant.fullOnDark => YawBrandAssets.logoFullOnDark,
      YawLogoVariant.horizontal => YawBrandAssets.logoHorizontal,
      YawLogoVariant.horizontalOnDark => YawBrandAssets.logoHorizontalOnDark,
      YawLogoVariant.stacked => YawBrandAssets.logoStacked,
      YawLogoVariant.stackedOnDark => YawBrandAssets.logoStackedOnDark,
      YawLogoVariant.icon => YawBrandAssets.appIcon,
    };
  }
}
