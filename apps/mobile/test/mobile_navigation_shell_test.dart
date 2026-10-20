import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/navigation/mobile_navigation_shell.dart';
import 'package:mobile/core/theme/app_theme.dart';

void main() {
  testWidgets(
    'tabs switch, system back returns home, details cover navigation',
    (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: StatefulBuilder(
            builder: (context, setState) => MobileNavigationShell(
              selectedIndex: selected,
              onDestinationSelected: (value) =>
                  setState(() => selected = value),
              onBackToHome: () => setState(() => selected = 0),
              child: Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Detail')),
                        ),
                      ),
                    ),
                    child: const Text('Open detail'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(selected, 0);
      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('compact screen with large text and gesture inset fits tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            padding: EdgeInsets.only(bottom: 24),
            textScaler: TextScaler.linear(2),
          ),
          child: MobileNavigationShell(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            onBackToHome: () {},
            child: const Scaffold(),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('You'), findsOneWidget);
  });

  test('system bars use readable icons for both device themes', () {
    expect(
      AppTheme.light.appBarTheme.systemOverlayStyle!.statusBarIconBrightness,
      Brightness.dark,
    );
    expect(
      AppTheme.dark.appBarTheme.systemOverlayStyle!.statusBarIconBrightness,
      Brightness.light,
    );
    expect(
      AppTheme.systemBars(Brightness.dark).systemNavigationBarIconBrightness,
      Brightness.light,
    );
    expect(
      AppTheme.systemBars(Brightness.light).statusBarColor,
      Colors.transparent,
    );
  });
}
