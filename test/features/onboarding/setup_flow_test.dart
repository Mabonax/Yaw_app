import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaw_app/app/theme/yaw_theme.dart';
import 'package:yaw_app/design_preview.dart';
import 'package:yaw_app/features/onboarding/data/registration_draft.dart';
import 'package:yaw_app/features/onboarding/presentation/pilot_setup_flow.dart';
import 'package:yaw_app/features/onboarding/presentation/account_created_screen.dart';
import 'package:yaw_app/features/dashboard/presentation/dashboard_view.dart';

void main() {
  setUpAll(() async {
    final regular = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
    await regular.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (var step = 0; step < 6; step++) {
    testWidgets('reference screen $step renders at phone size', (tester) async {
      debugDisableShadows = false;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 849);
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 16);
      addTearDown(tester.view.reset);
      final child = switch (step) {
        < 4 => PilotSetupFlow(
          draft: step == 0 || step == 1 || step == 2
              ? RegistrationDraft()
              : previewDraft(),
          initialStep: step,
          onBack: () {},
          onSignIn: () {},
        ),
        4 => AccountCreatedScreen(onLogin: () {}, onDashboard: () {}),
        _ => Scaffold(
          body: previewDashboard(),
          bottomNavigationBar: YawBottomNavigation(index: 0, onChanged: (_) {}),
        ),
      };
      await tester.pumpWidget(
        MaterialApp(
          theme: YawTheme.light(),
          home: RepaintBoundary(key: const ValueKey('screen'), child: child),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byKey(const ValueKey('screen')));
        for (final path in [
          'assets/screens/mountain_lake.png',
          'assets/role/yaw_role_mountain.png',
          'assets/screens/aircraft_reference.png',
          'assets/brand/yaw_logo_1x/icon.png',
        ]) {
          await precacheImage(AssetImage(path), context);
        }
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('screen')),
        matchesGoldenFile('goldens/screen_$step.png'),
      );
      debugDisableShadows = true;
    });
  }
  for (final size in [const Size(320, 568), const Size(412, 915)]) {
    for (var step = 0; step < 4; step++) {
      testWidgets('setup $step fits $size with larger text and keyboard', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        tester.view.viewInsets = const FakeViewPadding(bottom: 210);
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            theme: YawTheme.light(),
            home: PilotSetupFlow(
              draft: previewDraft(),
              initialStep: step,
              onBack: () {},
              onSignIn: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final button = find.text(
          step == 1
              ? 'Next'
              : step == 3
              ? 'Create Account'
              : 'Continue',
        );
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'draft navigation retains input and never claims account creation',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 849);
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 16);
      addTearDown(tester.view.reset);
      final draft = previewDraft();
      await tester.pumpWidget(
        MaterialApp(
          theme: YawTheme.light(),
          home: PilotSetupFlow(draft: draft, onBack: () {}, onSignIn: () {}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('name')),
        'Updated Pilot',
      );
      await _tap(tester, find.text('Continue'));
      expect(find.text('Select Aircraft Type'), findsOneWidget);
      await _tap(tester, find.text('DJI Mini 4 Pro'));
      expect(draft.model, 'Mini 4 Pro');
      await _tap(tester, find.text('Next'));
      await _tap(tester, find.text('Continue'));
      expect(find.text('Updated Pilot'), findsOneWidget);
      expect(find.text('DJI Mini 4 Pro'), findsOneWidget);
      await _tap(tester, find.byType(Checkbox));
      await _tap(tester, find.text('Create Account'));
      expect(
        find.text('Account creation is not available yet'),
        findsOneWidget,
      );
      expect(find.text('Account Created!'), findsNothing);
      await _tap(tester, find.text('Keep reviewing'));
      await _tap(tester, find.text('Edit').first);
      expect(find.byKey(const ValueKey('name')), findsOneWidget);
      expect(draft.name, 'Updated Pilot');
    },
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
