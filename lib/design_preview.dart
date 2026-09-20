// Isolated visual review entry point. No API clients, tokens or real accounts.
import 'package:flutter/material.dart';
import 'app/theme/yaw_theme.dart';
import 'features/onboarding/data/registration_draft.dart';
import 'features/onboarding/presentation/pilot_setup_flow.dart';
import 'features/onboarding/presentation/account_created_screen.dart';
import 'features/dashboard/presentation/dashboard_view.dart';

void main() => runApp(const DesignPreviewApp());

class DesignPreviewApp extends StatelessWidget {
  const DesignPreviewApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'YAW · Design Preview',
    debugShowCheckedModeBanner: false,
    theme: YawTheme.light(),
    home: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(0.0, 430.0);
        return Center(
          child: SizedBox(
            width: width,
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(size: Size(width, constraints.maxHeight)),
              child: const _PreviewGallery(),
            ),
          ),
        );
      },
    ),
  );
}

RegistrationDraft previewDraft() => RegistrationDraft()
  ..name = 'John Tshwarelo Mabona'
  ..email = 'john@example.com'
  ..phone = '82 123 4567'
  ..dateOfBirth = DateTime(1989, 1, 30)
  ..manufacturer = 'DJI'
  ..model = 'Mavic 3'
  ..serial = '1581F6ZC1234'
  ..registration = 'ZS-DRN-001'
  ..licences.first.number = 'RPL001234'
  ..licences.first.expiresAt = DateTime(2027, 8, 15)
  ..medicals.first.number = 'MED001234'
  ..medicals.first.expiresAt = DateTime(2027, 4, 30)
  ..confirmed = true;

Widget previewDashboard({ValueChanged<int>? onAction}) => DashboardView(
  name: 'John Mabona',
  greeting: 'Good Morning,',
  aircraftCount: '2',
  missionCount: '1',
  certificationCount: '4',
  expiryCount: '3',
  onAction: onAction ?? (_) {},
  onAccount: () {},
  onNotifications: () {},
  onLearnMore: () {},
  activity: const [
    DashboardEntry(
      'Aircraft added',
      'DJI Mavic 3',
      Icons.check_circle,
      trailing: '2h ago',
      color: Color(0xFF0FAC7C),
    ),
    DashboardEntry(
      'Pilot licence verified',
      'RPL · SACAA',
      Icons.description,
      trailing: '1 day ago',
    ),
    DashboardEntry(
      'Mission planned',
      'Site Survey · Pretoria',
      Icons.calendar_month_outlined,
      trailing: '2 days ago',
    ),
    DashboardEntry(
      'Certificate expiring soon',
      'Medical Certificate',
      Icons.warning_rounded,
      trailing: '3 days ago',
      color: Color(0xFFF6AC00),
    ),
  ],
  upcoming: const [
    DashboardEntry(
      '15 Sep 2026',
      'Site Survey\nPretoria, GP',
      Icons.calendar_month_outlined,
    ),
    DashboardEntry(
      '28 Sep 2026',
      'Inspection Flight\nMidrand, GP',
      Icons.calendar_month_outlined,
    ),
    DashboardEntry(
      '10 Oct 2026',
      'RPL Expiry\nRenewal required',
      Icons.info,
      color: Color(0xFFF6AC00),
    ),
  ],
);

class _PreviewGallery extends StatefulWidget {
  const _PreviewGallery();
  @override
  State<_PreviewGallery> createState() => _PreviewGalleryState();
}

class _PreviewGalleryState extends State<_PreviewGallery> {
  int page = const int.fromEnvironment('YAW_PREVIEW_SCREEN', defaultValue: 0);
  final draft = previewDraft();
  void select(int index) => setState(() => page = index);
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Banner(
      message: 'PREVIEW',
      location: BannerLocation.topEnd,
      child: switch (page) {
        < 4 => PilotSetupFlow(
          key: ValueKey(page),
          draft: page == 0 ? RegistrationDraft() : draft,
          initialStep: page,
          onBack: () => select(0),
          onSignIn: () => select(4),
        ),
        4 => AccountCreatedScreen(
          onLogin: () => select(0),
          onDashboard: () => select(5),
        ),
        _ => Scaffold(
          body: previewDashboard(
            onAction: (i) => select(
              i == 1
                  ? 1
                  : i == 2
                  ? 0
                  : 2,
            ),
          ),
          bottomNavigationBar: YawBottomNavigation(index: 0, onChanged: (_) {}),
        ),
      },
    ),
    floatingActionButton: FloatingActionButton.small(
      tooltip: 'Preview screens',
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, label) in [
                'Pilot Profile',
                'Add Aircraft',
                'Certifications',
                'Review Details',
                'Account Created',
                'Dashboard',
              ].indexed)
                ListTile(
                  title: Text(label),
                  onTap: () {
                    Navigator.pop(context);
                    select(i);
                  },
                ),
            ],
          ),
        ),
      ),
      child: const Icon(Icons.grid_view),
    ),
  );
}
