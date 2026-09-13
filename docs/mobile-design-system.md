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