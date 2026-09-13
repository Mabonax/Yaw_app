# YAW Mobile Design System

## Visual Direction

YAW mobile should feel like a professional aviation operations product:

- Blue and white as the primary identity.
- Clean operational surfaces.
- Dark navy and charcoal text.
- Restrained neutral greys.
- Green for healthy, ready, compliant states.
- Amber for warning, expiring, action-required states.
- Red for grounded, critical, non-compliant states.

Avoid neon, excessive gradients, heavy glassmorphism, and decorative tech imagery.

## Tokens

Tokens live in:

```text
lib/app/theme/yaw_tokens.dart
```

Token groups:

- `YawColors`
- `YawSpacing`
- `YawRadius`
- `YawElevation`
- `YawSizing`

The theme lives in:

```text
lib/app/theme/yaw_theme.dart
```

## Components

Reusable components live in:

```text
lib/core/widgets/yaw_widgets.dart
```

Implemented components:

- `YawScaffold`
- `YawAppBar`
- `YawCard`
- `YawSectionCard`
- `YawPrimaryButton`
- `YawSecondaryButton`
- `YawTextField`
- `YawDropdown`
- `YawStatusChip`
- `YawComplianceBadge`
- `YawReadinessIndicator`
- `YawMetricCard`
- `YawListTile`
- `YawEmptyState`
- `YawErrorState`
- `YawLoadingState`
- `YawSkeleton`
- `YawConfirmationSheet`
- `YawInfoRow`
- `YawSectionHeader`

## UX Requirements

The foundation supports:

- safe areas
- keyboard-safe login form scrolling
- touch-sized buttons
- bottom navigation
- reusable empty/error/loading states
- phone-first layouts with constrained widths for larger screens

## Reference Adaptation

The reference Flutter app informed the use of:

- centralized theme tokens
- section cards
- message/empty/loading states
- bottom-navigation shell
- feature-oriented folders

No reference app business logic, API routes, or medical terminology was copied.

## M1 Update - Branding Assets

Registered asset directories:

```yaml
flutter:
  assets:
    - assets/yaw logo versions/SVG/
    - assets/yaw logo versions/png logo/
```

Centralized paths live in:

```text
lib/core/branding/yaw_brand_assets.dart
lib/core/branding/yaw_logo.dart
```

Current usage:

- Splash: app icon with text SVG.
- Login: horizontal SVG for white background.
- Authenticated app shell: compact icon SVG.
- More/Profile header: compact icon SVG with account context.

Asset selection guidance:

- White backgrounds: `logo horizontal.svg`, `logo stacked.svg`, `icon.svg`.
- Blue/dark backgrounds: `logo horizontal on black bg.svg`, `logo stacked on black bg.svg`.
- Splash screens: `app icon with text rounded rectagle.svg` or `icon.svg` depending on available space.
- Compact headers/app bars: `icon.svg`.
- Authentication screens: `logo horizontal.svg`.
