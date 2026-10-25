import 'package:flutter/material.dart';

import 'result_range.dart';

class ResultPalette {
  const ResultPalette(this.foreground, this.background, this.icon);

  final Color foreground;
  final Color background;
  final IconData icon;

  static ResultPalette forPosition(
    BuildContext context,
    RangePosition position,
  ) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (position) {
      RangePosition.within => ResultPalette(
        dark ? const Color(0xFF8FE0AD) : const Color(0xFF166534),
        dark ? const Color(0xFF163526) : const Color(0xFFE8F5EC),
        Icons.check_circle_outline_rounded,
      ),
      RangePosition.below => ResultPalette(
        colors.onErrorContainer,
        colors.errorContainer,
        Icons.south_rounded,
      ),
      RangePosition.above => ResultPalette(
        colors.onErrorContainer,
        colors.errorContainer,
        Icons.north_rounded,
      ),
      RangePosition.unknown => ResultPalette(
        colors.onSurfaceVariant,
        colors.surfaceContainerLow,
        Icons.help_outline_rounded,
      ),
    };
  }
}
