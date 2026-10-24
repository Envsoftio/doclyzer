import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/screens/startup_loading_screen.dart';

void main() {
  testWidgets('startup screen follows light and dark app themes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(mode),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const StartupLoadingScreen(),
        ),
      );
      final expected = mode == ThemeMode.dark ? AppTheme.dark : AppTheme.light;
      final title = tester.widget<Text>(find.text('doclyzer'));
      final loading = tester.widget<Text>(find.text('Getting things ready…'));
      final subtitle = tester.widget<Text>(
        find.text('Your reports. A clearer picture.'),
      );

      expect(title.style?.color, expected.colorScheme.onSurface);
      expect(loading.style?.color, expected.colorScheme.onSurface);
      expect(subtitle.style?.color, expected.colorScheme.onSurfaceVariant);
      expect(
        find.byKey(const Key('startup-loading-indicator')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
