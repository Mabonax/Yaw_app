import 'package:flutter/material.dart';

import '../../onboarding/presentation/setup_widgets.dart';

class DashboardEntry {
  const DashboardEntry(
    this.title,
    this.subtitle,
    this.icon, {
    this.trailing = '',
    this.color = setupBlue,
  });
  final String title, subtitle, trailing;
  final IconData icon;
  final Color color;
}

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.name,
    required this.aircraftCount,
    required this.missionCount,
    this.certificationCount = '—',
    this.expiryCount = '—',
    this.greeting,
    this.activity = const [],
    this.upcoming = const [],
    required this.onAction,
    required this.onNotifications,
    required this.onAccount,
    required this.onLearnMore,
    this.notice,
    this.loading = false,
  });
  final String name,
      aircraftCount,
      missionCount,
      certificationCount,
      expiryCount;
  final String? greeting;
  final List<DashboardEntry> activity, upcoming;
  final ValueChanged<int> onAction;
  final VoidCallback onNotifications, onAccount, onLearnMore;
  final Widget? notice;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width.clamp(320.0, 500.0);
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();
    return Theme(
      data: setupTheme(context),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: width * .76 + MediaQuery.paddingOf(context).top,
            child: Stack(
              children: [
                const Positioned.fill(child: SetupScenery()),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 12,
                  left: 18,
                  right: 18,
                  child: Row(
                    children: [
                      const SetupLogo(horizontal: true),
                      const Spacer(),
                      IconButton(
                        onPressed: onNotifications,
                        tooltip: 'Notifications',
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          color: setupNavy,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onAccount,
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF0868B5),
                          child: Text(
                            initials.isEmpty ? 'Y' : initials,
                            style: setupText(10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 24,
                  top: MediaQuery.paddingOf(context).top + 100,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: .75),
                          blurRadius: 32,
                          spreadRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting ?? _greeting(),
                          style: setupText(14, color: setupMuted),
                        ),
                        Text(
                          name.split(' ').first,
                          style: setupText(
                            25,
                            weight: FontWeight.w600,
                          ).copyWith(letterSpacing: -.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Plan safer flights.\nStay compliant.\nGo further.',
                          style: setupText(10.5, color: setupMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 25,
                  bottom: 43,
                  child: Text(
                    'HIGHER\nSTANDARDS\nSAFER SKIES',
                    style: setupText(
                      6,
                      color: Colors.white,
                    ).copyWith(letterSpacing: 1.7, height: 1.8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                if (loading) const LinearProgressIndicator(minHeight: 2),
                ?notice,
                Row(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(width: 9),
                      Expanded(child: _quick(i)),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metric(
                      aircraftCount,
                      'Aircraft',
                      Icons.flight_outlined,
                      const Color(0xFFEAF5FF),
                      setupNavy,
                      1,
                      drone: true,
                    ),
                    const SizedBox(width: 9),
                    _metric(
                      certificationCount,
                      'Active\nCertificates',
                      Icons.fact_check_outlined,
                      const Color(0xFFECFAF8),
                      setupNavy,
                      3,
                    ),
                    const SizedBox(width: 9),
                    _metric(
                      expiryCount,
                      'Upcoming\nExpiries',
                      Icons.calendar_month_outlined,
                      const Color(0xFFFFF8E5),
                      const Color(0xFFF5B52D),
                      3,
                    ),
                    const SizedBox(width: 9),
                    _metric(
                      missionCount,
                      'Planned\nMissions',
                      Icons.location_on,
                      const Color(0xFFEAF5FF),
                      setupBlue,
                      0,
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _listPanel(
                        'Recent Activity',
                        activity,
                        () => onAction(3),
                        empty: 'Your operational updates will appear here.',
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      flex: 2,
                      child: _listPanel(
                        'Upcoming',
                        upcoming,
                        () => onAction(0),
                        empty: 'No upcoming missions.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  constraints: const BoxConstraints(minHeight: 89),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    image: const DecorationImage(
                      image: AssetImage('assets/screens/mountain_lake.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Color(0xD5003B70),
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smarter Operations.\nSafer Skies.',
                              style: setupText(
                                14,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Plan. Monitor. Comply. All in one place.',
                              style: setupText(7.5, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: onLearnMore,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          side: const BorderSide(color: Colors.white60),
                          shape: const StadiumBorder(),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Learn More',
                              style: setupText(8, color: Colors.white),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() => DateTime.now().hour < 12
      ? 'Good Morning,'
      : DateTime.now().hour < 18
      ? 'Good Afternoon,'
      : 'Good Evening,';
  Widget _quick(int index) => InkWell(
    onTap: () => onAction(index),
    borderRadius: BorderRadius.circular(9),
    child: SetupCard(
      padding: const EdgeInsets.fromLTRB(3, 17, 3, 11),
      color: Colors.white.withValues(alpha: .92),
      child: Column(
        children: [
          SizedBox(
            height: 28,
            child: index == 1
                ? const Center(child: DroneIcon(size: 35))
                : Icon(
                    [
                      Icons.map_outlined,
                      Icons.flight_outlined,
                      Icons.person_outline,
                      Icons.fact_check_outlined,
                    ][index],
                    size: 26,
                    color: const Color(0xFF16558E),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  [
                    'Plan Mission',
                    'My Aircraft',
                    'My Profile',
                    'Compliance',
                  ][index],
                  style: setupText(7.2, weight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, size: 12, color: setupNavy),
            ],
          ),
        ],
      ),
    ),
  );
  Widget _metric(
    String value,
    String label,
    IconData icon,
    Color background,
    Color color,
    int action, {
    bool drone = false,
  }) => Expanded(
    child: InkWell(
      onTap: () => onAction(action),
      child: SetupCard(
        color: background,
        padding: const EdgeInsets.fromLTRB(9, 12, 5, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              child: drone
                  ? DroneIcon(size: 25, color: color)
                  : Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 7),
            Text(value, style: setupText(22, weight: FontWeight.w600)),
            Row(
              children: [
                Expanded(child: Text(label, style: setupText(7.5))),
                const Icon(Icons.chevron_right, size: 13, color: setupMuted),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  Widget _listPanel(
    String title,
    List<DashboardEntry> entries,
    VoidCallback onOpen, {
    required String empty,
  }) => SetupCard(
    padding: const EdgeInsets.fromLTRB(10, 10, 8, 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: setupText(10, weight: FontWeight.w600)),
            ),
            InkWell(
              onTap: onOpen,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text('View All', style: setupText(7, color: setupBlue)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(empty, style: setupText(9, color: setupMuted)),
          ),
        for (final entry in entries.take(4))
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry.color.withValues(alpha: .09),
                    ),
                    child: Icon(entry.icon, size: 15, color: entry.color),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: setupText(8, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.subtitle,
                          style: setupText(7, color: setupMuted),
                        ),
                      ],
                    ),
                  ),
                  if (entry.trailing.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 2),
                      child: Text(
                        entry.trailing,
                        style: setupText(6, color: setupMuted),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class YawBottomNavigation extends StatelessWidget {
  const YawBottomNavigation({
    super.key,
    required this.index,
    required this.onChanged,
  });
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: setupBackground,
      border: Border(top: BorderSide(color: Color(0xFFEDF1F6))),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 9),
        child: Row(
          children: [
            for (var i = 0; i < 5; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onChanged(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          child: i == 2
                              ? DroneIcon(
                                  size: 27,
                                  color: index == i ? setupBlue : setupMuted,
                                )
                              : Icon(
                                  [
                                    index == 0
                                        ? Icons.home_rounded
                                        : Icons.home_outlined,
                                    Icons.map_outlined,
                                    Icons.flight_outlined,
                                    Icons.fact_check_outlined,
                                    Icons.menu,
                                  ][i],
                                  size: 22,
                                  color: index == i ? setupBlue : setupMuted,
                                ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          [
                            'Home',
                            'Missions',
                            'Aircraft',
                            'Compliance',
                            'More',
                          ][i],
                          style: setupText(
                            8,
                            color: index == i ? setupBlue : setupMuted,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          height: 1.5,
                          width: 35,
                          color: index == i ? setupBlue : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
