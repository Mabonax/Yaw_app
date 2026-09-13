import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../data/aircraft_models.dart';
import 'aircraft_controller.dart';

class AircraftListScreen extends StatefulWidget {
  const AircraftListScreen({super.key, required this.controller});

  final AircraftController controller;

  @override
  State<AircraftListScreen> createState() => _AircraftListScreenState();
}

class _AircraftListScreenState extends State<AircraftListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.state.status == AircraftLoadStatus.idle) {
      widget.controller.loadAircraft();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        return RefreshIndicator(
          onRefresh: () => widget.controller.loadAircraft(refresh: true),
          child: ListView(
            padding: const EdgeInsets.all(YawSpacing.page),
            children: [
              YawSectionHeader(
                title: 'Aircraft',
                subtitle: 'Readiness and package status from /api/v1/aircraft.',
              ),
              _AircraftSummaryStrip(state: state),
              const SizedBox(height: YawSpacing.lg),
              YawSecondaryButton(
                label: 'Browse catalogue',
                icon: Icons.inventory_2_outlined,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AircraftCatalogueScreen(controller: widget.controller),
                  ),
                ),
              ),
              const SizedBox(height: YawSpacing.lg),
              if (state.status == AircraftLoadStatus.loading) ...[
                const _AircraftSkeletonList(),
              ] else if (state.status == AircraftLoadStatus.failure) ...[
                YawErrorState(
                  title: 'Aircraft could not be loaded',
                  message: state.errorMessage ?? 'Try again.',
                  action: YawSecondaryButton(
                    label: 'Retry',
                    icon: Icons.refresh,
                    onPressed: widget.controller.loadAircraft,
                  ),
                ),
              ] else if (state.status == AircraftLoadStatus.empty) ...[
                const YawEmptyState(
                  title: 'No aircraft assigned',
                  message:
                      'The aircraft endpoint returned no records for this account.',
                ),
              ] else ...[
                for (final aircraft in state.aircraft) ...[
                  AircraftCard(
                    aircraft: aircraft,
                    onTap: () => _openAircraft(context, aircraft),
                  ),
                  const SizedBox(height: YawSpacing.md),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAircraft(BuildContext context, YawAircraft aircraft) async {
    await widget.controller.loadAircraftDetail(aircraft.id);
    if (!context.mounted) {
      return;
    }

    final selected = widget.controller.state.selectedAircraft ?? aircraft;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AircraftDetailScreen(aircraft: selected),
      ),
    );
  }
}

class AircraftCatalogueScreen extends StatefulWidget {
  const AircraftCatalogueScreen({super.key, required this.controller});

  final AircraftController controller;

  @override
  State<AircraftCatalogueScreen> createState() =>
      _AircraftCatalogueScreenState();
}

class _AircraftCatalogueScreenState extends State<AircraftCatalogueScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.controller.state.catalogueStatus == AircraftLoadStatus.idle) {
      widget.controller.loadCatalogue();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const YawAppBar(title: 'Aircraft catalogue'),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final state = widget.controller.state;

          return RefreshIndicator(
            onRefresh: () => widget.controller.loadCatalogue(refresh: true),
            child: ListView(
              padding: const EdgeInsets.all(YawSpacing.page),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search catalogue',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Search',
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => widget.controller.loadCatalogue(
                        refresh: true,
                        search: _searchController.text,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => widget.controller.loadCatalogue(
                    refresh: true,
                    search: value,
                  ),
                ),
                const SizedBox(height: YawSpacing.lg),
                if (state.catalogueStatus == AircraftLoadStatus.loading) ...[
                  const _AircraftSkeletonList(),
                ] else if (state.catalogueStatus ==
                    AircraftLoadStatus.failure) ...[
                  YawErrorState(
                    title: 'Catalogue could not be loaded',
                    message: state.catalogueErrorMessage ?? 'Try again.',
                    action: YawSecondaryButton(
                      label: 'Retry',
                      icon: Icons.refresh,
                      onPressed: widget.controller.loadCatalogue,
                    ),
                  ),
                ] else if (state.catalogueStatus ==
                    AircraftLoadStatus.empty) ...[
                  const YawEmptyState(
                    title: 'No catalogue models',
                    message:
                        'The aircraft catalogue endpoint returned no records.',
                  ),
                ] else ...[
                  for (final model in state.catalogue) ...[
                    CatalogueModelCard(
                      model: model,
                      onTap: () => _openCatalogueModel(context, model),
                    ),
                    const SizedBox(height: YawSpacing.md),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCatalogueModel(
    BuildContext context,
    YawAircraftCatalogueModel model,
  ) async {
    await widget.controller.loadCatalogueDetail(model.id);
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CatalogueDetailScreen(
          model: widget.controller.state.selectedCatalogueModel ?? model,
        ),
      ),
    );
  }
}

class AircraftDetailScreen extends StatelessWidget {
  const AircraftDetailScreen({super.key, required this.aircraft});

  final YawAircraft aircraft;

  @override
  Widget build(BuildContext context) {
    final readiness = aircraft.readiness;

    return Scaffold(
      appBar: YawAppBar(title: aircraft.registration ?? 'Aircraft detail'),
      body: ListView(
        padding: const EdgeInsets.all(YawSpacing.page),
        children: [
          _AircraftHero(aircraft: aircraft),
          const SizedBox(height: YawSpacing.lg),
          if (readiness != null) ...[
            AircraftReadinessCard(readiness: readiness),
            const SizedBox(height: YawSpacing.lg),
          ],
          YawSectionCard(
            title: 'Aircraft identity',
            subtitle: 'Physical aircraft record from the backend.',
            child: Column(
              children: [
                YawInfoRow(
                  label: 'Registration',
                  value: aircraft.registration ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Manufacturer',
                  value: aircraft.manufacturer ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Model',
                  value: aircraft.model ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Serial number',
                  value: aircraft.serialNumber ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Asset number',
                  value: aircraft.internalAssetNumber ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Base location',
                  value: aircraft.baseLocation ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Operator',
                  value: aircraft.operatorNames.isEmpty
                      ? aircraft.operator ?? 'Not supplied'
                      : aircraft.operatorNames.join(', '),
                ),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.lg),
          AircraftPackageCard(package: aircraft.packageInstantiation),
          const SizedBox(height: YawSpacing.lg),
          AircraftCatalogueContextCard(model: aircraft.catalogueModel),
        ],
      ),
    );
  }
}

class CatalogueDetailScreen extends StatelessWidget {
  const CatalogueDetailScreen({super.key, required this.model});

  final YawAircraftCatalogueModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YawAppBar(title: model.displayName),
      body: ListView(
        padding: const EdgeInsets.all(YawSpacing.page),
        children: [
          CatalogueModelCard(model: model),
          const SizedBox(height: YawSpacing.lg),
          YawSectionCard(
            title: 'Performance envelope',
            subtitle: 'Governed catalogue attributes.',
            child: Column(
              children: [
                YawInfoRow(
                  label: 'Aircraft type',
                  value: _format(model.aircraftType),
                ),
                YawInfoRow(
                  label: 'Primary use',
                  value: _format(model.primaryUse),
                ),
                YawInfoRow(
                  label: 'MTOW',
                  value: _formatMeasure(model.mtowKg, 'kg'),
                ),
                YawInfoRow(
                  label: 'Payload',
                  value: _formatMeasure(model.maxPayloadKg, 'kg'),
                ),
                YawInfoRow(
                  label: 'Flight time',
                  value: _formatMeasure(model.maxFlightTimeMin, 'min'),
                ),
                YawInfoRow(
                  label: 'Max wind',
                  value: _formatMeasure(model.maxWindMS, 'm/s'),
                ),
                YawInfoRow(label: 'GNSS', value: _format(model.gnss)),
                YawInfoRow(label: 'Remote ID', value: _format(model.remoteId)),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.lg),
          YawSectionCard(
            title: 'Package definition',
            subtitle:
                'Catalogue package used by the backend to instantiate aircraft assets.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: YawSpacing.sm,
                  runSpacing: YawSpacing.sm,
                  children: [
                    YawStatusChip(
                      label: '${model.packageCounts.batteries} batteries',
                      tone: YawStatusTone.info,
                      icon: Icons.battery_charging_full_outlined,
                    ),
                    YawStatusChip(
                      label: '${model.packageCounts.components} components',
                      tone: YawStatusTone.info,
                      icon: Icons.settings_input_component_outlined,
                    ),
                    YawStatusChip(
                      label:
                          '${model.packageCounts.maintenanceBaselines} baselines',
                      tone: YawStatusTone.info,
                      icon: Icons.build_circle_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: YawSpacing.md),
                YawInfoRow(
                  label: 'Package status',
                  value: _format(model.packageStatus),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AircraftCard extends StatelessWidget {
  const AircraftCard({super.key, required this.aircraft, this.onTap});

  final YawAircraft aircraft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final readiness = aircraft.readiness;

    return YawCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(YawRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(YawSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.flight_outlined,
                    color: YawColors.aviationBlue,
                  ),
                  const SizedBox(width: YawSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aircraft.displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: YawSpacing.xs),
                        Text(
                          aircraft.registration ?? 'Registration pending',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: YawColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (readiness != null)
                    YawStatusChip(
                      label: readiness.label ?? _format(readiness.status),
                      tone: _toneForReadiness(readiness.status),
                      icon: Icons.verified_outlined,
                    ),
                ],
              ),
              const SizedBox(height: YawSpacing.md),
              Wrap(
                spacing: YawSpacing.sm,
                runSpacing: YawSpacing.sm,
                children: [
                  YawStatusChip(
                    label: _format(aircraft.operationalStatus),
                    tone: _toneForOperationalStatus(aircraft.operationalStatus),
                  ),
                  YawStatusChip(
                    label:
                        'Package ${_format(aircraft.packageInstantiation.state)}',
                    tone: aircraft.packageInstantiation.state == 'instantiated'
                        ? YawStatusTone.healthy
                        : YawStatusTone.warning,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogueModelCard extends StatelessWidget {
  const CatalogueModelCard({super.key, required this.model, this.onTap});

  final YawAircraftCatalogueModel model;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return YawCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(YawRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CatalogueImage(model: model),
            const SizedBox(height: YawSpacing.md),
            Text(
              model.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: YawSpacing.xs),
            Text(
              [
                _format(model.aircraftType),
                _format(model.primaryUse),
                _format(model.catalogueStatus),
              ].where((part) => part != 'Not supplied').join(' · '),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: YawColors.textMuted),
            ),
            const SizedBox(height: YawSpacing.md),
            Wrap(
              spacing: YawSpacing.sm,
              runSpacing: YawSpacing.sm,
              children: [
                YawStatusChip(
                  label: _format(model.packageStatus),
                  tone: model.packageStatus == 'complete'
                      ? YawStatusTone.healthy
                      : YawStatusTone.warning,
                ),
                YawStatusChip(
                  label: '${model.packageCounts.components} components',
                  tone: YawStatusTone.info,
                ),
                YawStatusChip(
                  label: '${model.packageCounts.batteries} batteries',
                  tone: YawStatusTone.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AircraftReadinessCard extends StatelessWidget {
  const AircraftReadinessCard({super.key, required this.readiness});

  final YawAircraftReadiness readiness;

  @override
  Widget build(BuildContext context) {
    return YawSectionCard(
      title: 'Release readiness',
      subtitle: readiness.asOf == null
          ? 'Server-calculated readiness summary.'
          : 'Server-calculated as of ${readiness.asOf}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YawReadinessIndicator(
            label: readiness.label ?? _format(readiness.status),
            value: readiness.completionRatio,
            tone: _toneForReadiness(readiness.status),
          ),
          const SizedBox(height: YawSpacing.md),
          for (final check in readiness.checks) ...[
            YawListTile(
              title: check.label ?? _format(check.code),
              subtitle: check.summary,
              leading: Icon(
                _iconForReadiness(check.status),
                color: _toneForReadiness(check.status).colors.foreground,
              ),
              trailing: YawStatusChip(
                label: _format(check.status),
                tone: _toneForReadiness(check.status),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AircraftPackageCard extends StatelessWidget {
  const AircraftPackageCard({super.key, required this.package});

  final YawAircraftPackage package;

  @override
  Widget build(BuildContext context) {
    return YawSectionCard(
      title: 'Aircraft package',
      subtitle:
          'Batteries and components instantiated from the governed catalogue.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: YawSpacing.sm,
            runSpacing: YawSpacing.sm,
            children: [
              YawStatusChip(
                label: _format(package.state),
                tone: package.state == 'instantiated'
                    ? YawStatusTone.healthy
                    : YawStatusTone.warning,
              ),
              YawStatusChip(
                label: '${package.batteryCount} batteries',
                tone: YawStatusTone.info,
              ),
              YawStatusChip(
                label: '${package.componentCount} components',
                tone: YawStatusTone.info,
              ),
            ],
          ),
          const SizedBox(height: YawSpacing.md),
          if (package.batteries.isEmpty)
            const Text('No package batteries were returned for this aircraft.')
          else ...[
            Text('Batteries', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: YawSpacing.sm),
            for (final battery in package.batteries)
              YawListTile(
                title: battery.batteryUid ?? 'Battery #${battery.id}',
                subtitle: [
                  _format(battery.model),
                  _format(battery.packageItemKey),
                ].where((part) => part != 'Not supplied').join(' · '),
                leading: const Icon(Icons.battery_charging_full_outlined),
                trailing: YawStatusChip(
                  label: _format(battery.healthStatus),
                  tone: battery.healthStatus == 'serviceable'
                      ? YawStatusTone.healthy
                      : YawStatusTone.warning,
                ),
              ),
          ],
          const SizedBox(height: YawSpacing.md),
          if (package.components.isEmpty)
            const Text('No package components were returned for this aircraft.')
          else ...[
            Text('Components', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: YawSpacing.sm),
            for (final component in package.components)
              YawListTile(
                title: component.name ?? 'Component #${component.id}',
                subtitle: [
                  _format(component.componentType),
                  _format(component.packageItemKey),
                ].where((part) => part != 'Not supplied').join(' · '),
                leading: const Icon(Icons.settings_input_component_outlined),
                trailing: YawStatusChip(
                  label: _format(component.status),
                  tone: component.status == 'active'
                      ? YawStatusTone.healthy
                      : YawStatusTone.warning,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class AircraftCatalogueContextCard extends StatelessWidget {
  const AircraftCatalogueContextCard({super.key, required this.model});

  final YawAircraftCatalogueModel? model;

  @override
  Widget build(BuildContext context) {
    if (model == null) {
      return const YawEmptyState(
        title: 'No catalogue model linked',
        message:
            'This physical aircraft is not linked to a governed catalogue model.',
      );
    }

    return YawSectionCard(
      title: 'Catalogue context',
      subtitle: model!.displayName,
      child: Column(
        children: [
          YawInfoRow(
            label: 'Catalogue status',
            value: _format(model!.catalogueStatus),
          ),
          YawInfoRow(
            label: 'Package status',
            value: _format(model!.packageStatus),
          ),
          YawInfoRow(
            label: 'Verified at',
            value: model!.verifiedAt ?? 'Not supplied',
          ),
          YawInfoRow(
            label: 'Source',
            value: model!.sourceUrl ?? 'Not supplied',
          ),
        ],
      ),
    );
  }
}

class _AircraftSummaryStrip extends StatelessWidget {
  const _AircraftSummaryStrip({required this.state});

  final AircraftState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: YawSpacing.md,
      runSpacing: YawSpacing.md,
      children: [
        _SummaryPill(
          icon: Icons.flight_outlined,
          label: 'Aircraft',
          value: '${state.totalAircraft}',
          tone: YawStatusTone.info,
        ),
        _SummaryPill(
          icon: Icons.check_circle_outline,
          label: 'Ready',
          value: '${state.readyAircraft}',
          tone: YawStatusTone.healthy,
        ),
        _SummaryPill(
          icon: Icons.warning_amber_outlined,
          label: 'Review',
          value: '${state.reviewAircraft}',
          tone: YawStatusTone.warning,
        ),
        _SummaryPill(
          icon: Icons.block_outlined,
          label: 'Blocked',
          value: '${state.blockedAircraft}',
          tone: YawStatusTone.critical,
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final YawStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;

    return Container(
      width: 152,
      padding: const EdgeInsets.all(YawSpacing.md),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(YawRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.foreground),
          const SizedBox(width: YawSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                Text(label, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AircraftHero extends StatelessWidget {
  const _AircraftHero({required this.aircraft});

  final YawAircraft aircraft;

  @override
  Widget build(BuildContext context) {
    return YawCard(
      child: Row(
        children: [
          const Icon(Icons.airplanemode_active, size: 44),
          const SizedBox(width: YawSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aircraft.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: YawSpacing.xs),
                Text(
                  aircraft.registration ?? 'Registration pending',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: YawColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueImage extends StatelessWidget {
  const _CatalogueImage({required this.model});

  final YawAircraftCatalogueModel model;

  @override
  Widget build(BuildContext context) {
    final url = model.imageSourceUrl;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(YawRadius.md),
        child: ColoredBox(
          color: YawColors.border.withValues(alpha: 0.35),
          child: url == null
              ? const Icon(Icons.image_not_supported_outlined, size: 36)
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined, size: 36),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _AircraftSkeletonList extends StatelessWidget {
  const _AircraftSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          const YawCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                YawSkeleton(height: 24, width: 220),
                SizedBox(height: YawSpacing.md),
                YawSkeleton(height: 16, width: 160),
                SizedBox(height: YawSpacing.md),
                YawSkeleton(height: 36),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.md),
        ],
      ],
    );
  }
}

String _format(String? value) {
  if (value == null || value.isEmpty) {
    return 'Not supplied';
  }

  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _formatMeasure(num? value, String unit) {
  if (value == null) {
    return 'Not supplied';
  }

  return '$value $unit';
}

YawStatusTone _toneForReadiness(String? status) {
  return switch (status) {
    'green' => YawStatusTone.healthy,
    'amber' => YawStatusTone.warning,
    'red' => YawStatusTone.critical,
    _ => YawStatusTone.info,
  };
}

YawStatusTone _toneForOperationalStatus(String? status) {
  return switch (status) {
    'active' || 'serviceable' || 'released' => YawStatusTone.healthy,
    'grounded' || 'retired' || 'unserviceable' => YawStatusTone.critical,
    null => YawStatusTone.info,
    _ => YawStatusTone.warning,
  };
}

IconData _iconForReadiness(String? status) {
  return switch (status) {
    'green' => Icons.check_circle_outline,
    'amber' => Icons.warning_amber_outlined,
    'red' => Icons.error_outline,
    _ => Icons.info_outline,
  };
}
