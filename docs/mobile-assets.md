# YAW Mobile Asset Convention

The supplied assets under `assets/yaw logo versions/` are the authoritative YAW mobile branding source.

## Registered Bundles

```yaml
flutter:
  assets:
    - assets/yaw logo versions/SVG/
    - assets/yaw logo versions/png logo/
```

## Centralized Access

Use these files rather than raw string paths in widgets:

- `lib/core/branding/yaw_brand_assets.dart`
- `lib/core/branding/yaw_logo.dart`

## Variant Guidance

- White backgrounds: horizontal, stacked, or icon SVG without dark background.
- Dark/blue backgrounds: `on black bg` variants.
- Splash: app icon with text or icon variant.
- Login/auth: horizontal logo on white.
- Compact app bars: icon SVG.

Do not modify original logo files unless a dedicated asset-production task requests it.