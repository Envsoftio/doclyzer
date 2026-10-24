import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';

double _contrast(Color first, Color second) {
  final high = first.computeLuminance() > second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  final low = first.computeLuminance() < second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  return (high + 0.05) / (low + 0.05);
}

void main() {
  test('default snackbar text has readable contrast in both themes', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final snack = theme.snackBarTheme;
      expect(snack.backgroundColor, isNotNull);
      expect(snack.contentTextStyle?.color, isNotNull);
      expect(
        _contrast(snack.backgroundColor!, snack.contentTextStyle!.color!),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}
