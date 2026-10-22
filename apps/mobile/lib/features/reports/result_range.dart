import 'reports_repository.dart';

enum RangePosition { below, within, above, unknown }

String _normalizePrintedText(String raw) {
  const entities = {
    'lt': '<',
    'gt': '>',
    'le': '≤',
    'ge': '≥',
    'nbsp': ' ',
    'amp': '&',
    'ndash': '–',
    'mdash': '—',
    'minus': '-',
  };
  return raw
      .replaceAllMapped(
        RegExp(
          r'&(#x[0-9a-f]+|#\d+|lt|gt|le|ge|nbsp|amp|ndash|mdash|minus);',
          caseSensitive: false,
        ),
        (match) {
          final entity = match.group(1)!.toLowerCase();
          if (!entity.startsWith('#')) return entities[entity]!;
          final code = entity.startsWith('#x')
              ? int.tryParse(entity.substring(2), radix: 16)
              : int.tryParse(entity.substring(1));
          if (code == null ||
              code <= 0 ||
              code > 0x10ffff ||
              (code >= 0xd800 && code <= 0xdfff)) {
            return match.group(0)!;
          }
          return String.fromCharCode(code);
        },
      )
      .replaceAll(RegExp(r'<br\s*/?\s*>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\\(?:r\\n|n|r)?'), ' ')
      .replaceAll('−', '-')
      .replaceAll(RegExp(r'[\s\u00a0\u2000-\u200a\u202f\u205f\u3000]+'), ' ')
      .trim();
}

/// Selects a single explicitly printed preferred category from a complete
/// categorical lab range. Never supplies a population range from test knowledge.
String? preferredPrintedRange(String raw) {
  final normalized = _normalizePrintedText(raw);
  final category = RegExp(
    r'(?:Adult\s+)?(Desirable|Normal|Near or Above Optimal|Above Optimal|Near Optimal|Optimal|Borderline High|Borderline Low|Borderline|Very High|Very Low|High|Low)\s*:\s*((?:<=|>=|<|>|≤|≥)?\s*-?\d{1,5}(?:\.\d{1,6})?(?:\s*(?:[-–—]|to)\s*-?\d{1,5}(?:\.\d{1,6})?)?)(?=$|[\s;|])',
    caseSensitive: false,
  );
  final matches = category.allMatches(normalized).toList();
  if (matches.isEmpty || matches.length > 12) return null;
  if (normalized
      .replaceAll(category, '')
      .replaceAll(RegExp(r'[;|\s]'), '')
      .isNotEmpty) {
    return null;
  }
  final numeric = RegExp(
    r'^(?:(?:<=|>=|<|>|≤|≥)\s*-?\d{1,5}(?:\.\d{1,6})?|-?\d{1,5}(?:\.\d{1,6})?\s*(?:[-–—]|to)\s*-?\d{1,5}(?:\.\d{1,6})?)$',
    caseSensitive: false,
  );
  final bounds =
      <({double low, double high, bool includeLow, bool includeHigh})>[];
  for (final match in matches) {
    final candidate = match.group(2)!.trim();
    if (!numeric.hasMatch(candidate)) return null;
    final interval = _intervalPattern.firstMatch(candidate);
    if (interval != null) {
      final low = double.parse(interval.group(1)!);
      final high = double.parse(interval.group(2)!);
      if (low > high) return null;
      bounds.add((low: low, high: high, includeLow: true, includeHigh: true));
    } else {
      final limit = _limitPattern.firstMatch(candidate)!;
      final bound = double.parse(limit.group(2)!);
      bounds.add(switch (limit.group(1)!) {
        '<' => (
          low: double.negativeInfinity,
          high: bound,
          includeLow: false,
          includeHigh: false,
        ),
        '<=' || '≤' => (
          low: double.negativeInfinity,
          high: bound,
          includeLow: false,
          includeHigh: true,
        ),
        '>' => (
          low: bound,
          high: double.infinity,
          includeLow: false,
          includeHigh: false,
        ),
        _ => (
          low: bound,
          high: double.infinity,
          includeLow: true,
          includeHigh: false,
        ),
      });
    }
  }
  for (var i = 0; i < bounds.length; i++) {
    for (var j = i + 1; j < bounds.length; j++) {
      if (_overlaps(bounds[i], bounds[j])) return null;
    }
  }
  final preferred = matches.where((match) {
    return const {
      'desirable',
      'normal',
      'optimal',
    }.contains(match.group(1)!.toLowerCase());
  }).toList();
  if (preferred.length != 1) return null;
  return preferred.single.group(2)!.trim();
}

final _intervalPattern = RegExp(
  r'^\s*(-?\d+(?:\.\d+)?)\s*(?:[-–—]|to)\s*(-?\d+(?:\.\d+)?)\s*$',
  caseSensitive: false,
);

final _limitPattern = RegExp(r'^\s*(<=|>=|<|>|≤|≥)\s*(-?\d+(?:\.\d+)?)\s*$');

bool _overlaps(
  ({double low, double high, bool includeLow, bool includeHigh}) a,
  ({double low, double high, bool includeLow, bool includeHigh}) b,
) {
  final low = a.low > b.low ? a.low : b.low;
  final high = a.high < b.high ? a.high : b.high;
  if (low < high) return true;
  if (low > high) return false;
  bool contains(
    ({double low, double high, bool includeLow, bool includeHigh}) range,
  ) =>
      (low > range.low || range.includeLow) &&
      (low < range.high || range.includeHigh);
  return contains(a) && contains(b);
}

String unavailableRangeReason(ExtractedLabValue result) {
  if (result.parameterName.trim().isEmpty) {
    return 'The test name is missing from the extracted result.';
  }
  if (result.referenceRange?.trim().isNotEmpty != true) {
    return 'No lab reference range was captured for this test.';
  }
  if (double.tryParse(_normalizePrintedText(result.value)) == null) {
    return 'The extracted value is not a plain number. Check it in the original report.';
  }
  if (result.isAbnormal != null) {
    final withoutFlag = ExtractedLabValue(
      parameterName: result.parameterName,
      value: result.value,
      unit: result.unit,
      referenceRange: result.referenceRange,
    );
    final position = compareWithPrintedRange(withoutFlag);
    if (position != RangePosition.unknown &&
        result.isAbnormal != (position != RangePosition.within)) {
      return 'The lab flag conflicts with the printed range. Check the original report.';
    }
  }
  return 'The extracted value, printed range, or lab flag needs checking in the original report.';
}

/// Compare the result with its captured printed range. A separate unit field
/// is not needed for this same-row numeric comparison.
/// The printed range may not apply to every person.
RangePosition compareWithPrintedRange(ExtractedLabValue result) {
  final rawValue = _normalizePrintedText(result.value);
  final value = RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(rawValue)
      ? double.tryParse(rawValue)
      : null;
  final rawRange = result.referenceRange == null
      ? null
      : _normalizePrintedText(result.referenceRange!);
  final range = rawRange == null
      ? null
      : preferredPrintedRange(rawRange) ?? rawRange;
  if (result.parameterName.trim().isEmpty ||
      value == null ||
      !value.isFinite ||
      range == null ||
      range.isEmpty) {
    return RangePosition.unknown;
  }
  final interval = _intervalPattern.firstMatch(range);
  RangePosition position;
  if (interval != null) {
    final low = double.tryParse(interval.group(1)!);
    final high = double.tryParse(interval.group(2)!);
    if (low == null ||
        high == null ||
        !low.isFinite ||
        !high.isFinite ||
        low > high) {
      return RangePosition.unknown;
    }
    position = value < low
        ? RangePosition.below
        : value > high
        ? RangePosition.above
        : RangePosition.within;
  } else {
    final limit = _limitPattern.firstMatch(range);
    if (limit == null) return RangePosition.unknown;
    final bound = double.tryParse(limit.group(2)!);
    if (bound == null || !bound.isFinite) return RangePosition.unknown;
    position = switch (limit.group(1)!) {
      '<' => value < bound ? RangePosition.within : RangePosition.above,
      '<=' ||
      '≤' => value <= bound ? RangePosition.within : RangePosition.above,
      '>' => value > bound ? RangePosition.within : RangePosition.below,
      _ => value >= bound ? RangePosition.within : RangePosition.below,
    };
  }
  if (result.isAbnormal != null &&
      result.isAbnormal != (position != RangePosition.within)) {
    return RangePosition.unknown;
  }
  return position;
}
