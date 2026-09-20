import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/yaw_tokens.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../data/briefing_models.dart';
import 'briefing_controller.dart';

class MissionBriefingScreen extends StatefulWidget {
  const MissionBriefingScreen({super.key, required this.controller});
  final BriefingController controller;
  @override
  State<MissionBriefingScreen> createState() => _MissionBriefingScreenState();
}

class _MissionBriefingScreenState extends State<MissionBriefingScreen>
    with WidgetsBindingObserver {
  bool _reviewed = false;
  int? _reviewedBriefingId;
  Timer? _refresh;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.load();
    // Re-query the server; the client never computes expiry or release status.
    _refresh = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        widget.controller.load(revision: widget.controller.view?.revision);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.controller.load();
  }

  @override
  void dispose() {
    _refresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const YawAppBar(title: 'Pre-flight briefing'),
    body: ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final view = controller.view;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(YawSpacing.page),
            children: [
              if (controller.loading) const LinearProgressIndicator(),
              if (controller.error != null)
                YawErrorState(
                  title: 'Briefing unavailable',
                  message: controller.error!,
                  action: TextButton(
                    onPressed: controller.load,
                    child: const Text('Retry'),
                  ),
                ),
              if (view != null) ...[
                YawSectionCard(
                  title:
                      view.mission['mission_number']?.toString() ?? 'Mission',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          _status(view.status),
                          Chip(label: Text(view.freshness)),
                        ],
                      ),
                      const Text('Current release control supplied by YAW'),
                      for (final reason in view.reasons)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(reason),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: YawSpacing.md),
                for (final provider in view.providers) ...[
                  YawSectionCard(
                    title: provider['provider']?.toString() ?? 'Source',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'State: ${provider['health_status'] ?? provider['status']}',
                        ),
                        if (provider['reason'] != null)
                          Text(provider['reason'].toString()),
                        Text(
                          provider['operational_authority'] == true
                              ? 'Operational provider'
                              : 'Reference or unavailable provider',
                        ),
                        Text(
                          'Dataset: ${provider['dataset_timestamp'] ?? 'Unavailable'}',
                        ),
                        if (provider['required'] == true)
                          const Text('Required for release'),
                      ],
                    ),
                  ),
                  const SizedBox(height: YawSpacing.md),
                ],
                if (view.canGenerate)
                  FilledButton.icon(
                    onPressed: controller.loading
                        ? null
                        : () {
                            setState(() => _reviewed = false);
                            controller.generate();
                          },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate new briefing'),
                  ),
                const SizedBox(height: YawSpacing.md),
                if (view.id == null)
                  const YawEmptyState(
                    title: 'No briefing recorded',
                    message:
                        'Generate a briefing to capture the information presented for this mission.',
                  ),
                if (view.id != null) ...[
                  YawSectionCard(
                    title: 'Briefing revision ${view.revision}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Snapshot status: ${view.briefing['status']}'),
                        Text('Generated: ${view.briefing['generated_at']}'),
                        Text('Valid until: ${view.briefing['valid_until']}'),
                        if (view.briefing['empty_data_message'] != null)
                          Text(view.briefing['empty_data_message'].toString()),
                        if (view.acknowledged)
                          const Text('Acknowledgement recorded'),
                        if (view.acknowledgementRequired &&
                            !view.acknowledged &&
                            view.canAcknowledge) ...[
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'I have reviewed this briefing and its source references.',
                            ),
                            value: _reviewed && _reviewedBriefingId == view.id,
                            onChanged: controller.loading
                                ? null
                                : (value) => setState(() {
                                    _reviewed = value ?? false;
                                    _reviewedBriefingId = view.id;
                                  }),
                          ),
                          FilledButton(
                            onPressed:
                                controller.loading ||
                                    !_reviewed ||
                                    _reviewedBriefingId != view.id
                                ? null
                                : () async {
                                    await controller.acknowledge();
                                    if (mounted) {
                                      setState(() => _reviewed = false);
                                    }
                                  },
                            child: const Text('Acknowledge briefing'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: YawSpacing.md),
                  for (final item in view.items) ...[
                    YawSectionCard(
                      title: '${item.identifier} Â· ${item.type}',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(label: Text(item.severity)),
                              Chip(label: Text(item.releaseEffect)),
                            ],
                          ),
                          Text(item.reason),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BriefingItemScreen(item: item),
                              ),
                            ),
                            child: const Text('View source and interpretation'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: YawSpacing.md),
                  ],
                ],
                if (view.revisions.isNotEmpty)
                  YawSectionCard(
                    title: 'Briefing history',
                    child: Wrap(
                      spacing: 8,
                      children: view.revisions
                          .map(
                            (revision) => OutlinedButton(
                              onPressed: controller.loading
                                  ? null
                                  : () {
                                      setState(() => _reviewed = false);
                                      controller.load(
                                        revision: (revision['revision'] as num)
                                            .toInt(),
                                      );
                                    },
                              child: Text('Revision ${revision['revision']}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    ),
  );

  Widget _status(String status) => YawStatusChip(
    label: status,
    tone: switch (status) {
      'green' => YawStatusTone.healthy,
      'amber' => YawStatusTone.warning,
      'red' => YawStatusTone.critical,
      _ => YawStatusTone.info,
    },
  );
}

class BriefingItemScreen extends StatelessWidget {
  const BriefingItemScreen({super.key, required this.item});
  final YawBriefingItem item;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: YawAppBar(title: item.identifier),
    body: ListView(
      padding: const EdgeInsets.all(YawSpacing.page),
      children: [
        Text(item.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: YawSpacing.md),
        YawSectionCard(
          title: 'Source content',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.classification),
              Text(
                item.usableForRelease
                    ? 'Operational source; interpretation is shown separately.'
                    : 'Reference only. This item cannot establish operational clearance.',
              ),
              const SizedBox(height: 12),
              SelectableText(item.rawMessage),
              if (item.sourceUrl.isNotEmpty) ...[
                SelectableText(item.sourceUrl),
                TextButton(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: item.sourceUrl)),
                  child: const Text('Copy source reference'),
                ),
              ],
              ExpansionTile(
                title: const Text('Retained source payload'),
                children: [
                  SelectableText(item.pretty(item.source['raw_payload'])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: YawSpacing.md),
        YawSectionCard(
          title: 'YAW normalized interpretation',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.reason),
              SelectableText(
                const JsonEncoder.withIndent('  ').convert(item.interpretation),
              ),
            ],
          ),
        ),
        const SizedBox(height: YawSpacing.md),
        YawSectionCard(
          title: 'Applicability and provenance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${item.raw['effective_from'] ?? 'Unknown'}'),
              Text('Until: ${item.raw['effective_until'] ?? 'Unknown'}'),
              Text('Source revision: ${item.raw['source_revision']}'),
              SelectableText('Checksum: ${item.raw['checksum']}'),
              SelectableText('Geometry: ${item.pretty(item.raw['geometry'])}'),
            ],
          ),
        ),
      ],
    ),
  );
}
