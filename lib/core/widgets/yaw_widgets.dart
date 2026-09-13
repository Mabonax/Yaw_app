import 'package:flutter/material.dart';

import '../../app/theme/yaw_tokens.dart';

class YawScaffold extends StatelessWidget {
  const YawScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(child: body),
    );
  }
}

class YawAppBar extends StatelessWidget implements PreferredSizeWidget {
  const YawAppBar({super.key, required this.title, this.actions, this.leading});

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) =>
      AppBar(leading: leading, title: Text(title), actions: actions);
}

class YawCard extends StatelessWidget {
  const YawCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(YawSpacing.card),
      decoration: BoxDecoration(
        color: YawColors.surface,
        borderRadius: BorderRadius.circular(YawRadius.lg),
        border: Border.all(color: YawColors.border),
        boxShadow: YawElevation.card,
      ),
      child: child,
    );
  }
}

class YawSectionCard extends StatelessWidget {
  const YawSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return YawCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: YawSpacing.xs),
                      Text(
                        subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: YawColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ...?(action == null ? null : [action!]),
            ],
          ),
          const SizedBox(height: YawSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class YawPrimaryButton extends StatelessWidget {
  const YawPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final iconWidgets = icon == null
        ? null
        : <Widget>[
            Icon(icon, size: YawSizing.iconSm),
            const SizedBox(width: YawSpacing.sm),
          ];
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...?iconWidgets,
              Flexible(child: Text(label)),
            ],
          );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );
  }
}

class YawSecondaryButton extends StatelessWidget {
  const YawSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward, size: YawSizing.iconSm),
      label: Text(label),
    );
  }
}

class YawTextField extends StatelessWidget {
  const YawTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
    );
  }
}

class YawDropdown<T> extends StatelessWidget {
  const YawDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
    );
  }
}

class YawStatusChip extends StatelessWidget {
  const YawStatusChip({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final YawStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;

    return Chip(
      avatar: icon == null
          ? null
          : Icon(icon, size: YawSizing.iconSm, color: colors.foreground),
      label: Text(label),
      labelStyle: TextStyle(
        color: colors.foreground,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: colors.background,
      side: BorderSide(color: colors.foreground.withValues(alpha: 0.16)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YawRadius.sm),
      ),
    );
  }
}

class YawComplianceBadge extends StatelessWidget {
  const YawComplianceBadge({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final YawStatusTone tone;

  @override
  Widget build(BuildContext context) =>
      YawStatusChip(label: label, tone: tone, icon: Icons.verified_outlined);
}

class YawReadinessIndicator extends StatelessWidget {
  const YawReadinessIndicator({
    super.key,
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final double value;
  final YawStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            Text('${(value * 100).round()}%'),
          ],
        ),
        const SizedBox(height: YawSpacing.sm),
        LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: 8,
          color: colors.foreground,
          backgroundColor: colors.background,
          borderRadius: BorderRadius.circular(YawRadius.sm),
        ),
      ],
    );
  }
}

class YawMetricCard extends StatelessWidget {
  const YawMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tone = YawStatusTone.info,
  });

  final String label;
  final String value;
  final IconData icon;
  final YawStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;

    return YawCard(
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(YawRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(YawSpacing.md),
              child: Icon(icon, color: colors.foreground),
            ),
          ),
          const SizedBox(width: YawSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: YawSpacing.xs),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class YawListTile extends StatelessWidget {
  const YawListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: YawSpacing.md,
      leading: leading,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YawRadius.md),
      ),
    );
  }
}

class YawEmptyState extends StatelessWidget {
  const YawEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => YawMessageState(
    icon: Icons.inbox_outlined,
    title: title,
    message: message,
    action: action,
  );
}

class YawErrorState extends StatelessWidget {
  const YawErrorState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => YawMessageState(
    icon: Icons.error_outline,
    title: title,
    message: message,
    action: action,
    tone: YawStatusTone.critical,
  );
}

class YawLoadingState extends StatelessWidget {
  const YawLoadingState({super.key, this.message = 'Loading YAW workspace...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(YawSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 2.6),
            const SizedBox(height: YawSpacing.lg),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class YawSkeleton extends StatelessWidget {
  const YawSkeleton({super.key, this.height = 16, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: YawColors.border.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(YawRadius.sm),
      ),
    );
  }
}

class YawConfirmationSheet extends StatelessWidget {
  const YawConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(YawSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: YawSpacing.md),
          Text(message),
          const SizedBox(height: YawSpacing.xl),
          YawPrimaryButton(label: confirmLabel, onPressed: onConfirm),
        ],
      ),
    );
  }
}

class YawInfoRow extends StatelessWidget {
  const YawInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: YawSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: YawColors.textMuted),
            ),
          ),
          const SizedBox(width: YawSpacing.lg),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class YawSectionHeader extends StatelessWidget {
  const YawSectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: YawSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: YawSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: YawColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class YawMessageState extends StatelessWidget {
  const YawMessageState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.tone = YawStatusTone.info,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final YawStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(YawSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colors.foreground, size: 40),
              const SizedBox(height: YawSpacing.lg),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: YawSpacing.sm),
              Text(message, textAlign: TextAlign.center),
              if (action != null) ...[
                const SizedBox(height: YawSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum YawStatusTone { healthy, warning, critical, info }

extension YawStatusToneColors on YawStatusTone {
  ({Color background, Color foreground}) get colors {
    return switch (this) {
      YawStatusTone.healthy => (
        background: YawColors.healthySoft,
        foreground: YawColors.healthy,
      ),
      YawStatusTone.warning => (
        background: YawColors.warningSoft,
        foreground: YawColors.warning,
      ),
      YawStatusTone.critical => (
        background: YawColors.criticalSoft,
        foreground: YawColors.critical,
      ),
      YawStatusTone.info => (
        background: YawColors.infoSoft,
        foreground: YawColors.aviationBlue,
      ),
    };
  }
}
