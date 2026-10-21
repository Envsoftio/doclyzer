import 'reports_repository.dart';

enum RangePosition { below, within, above, unknown }

/// Selects a single explicitly printed preferred category from a complete
/// categorical lab range. Never supplies a population range from test knowledge.
String? preferredPrintedRange(String raw) {
  final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  final category = RegExp(
    r'(?:Adult\s+)?(?:Desirable|Normal|Optimal|Borderline|Very High|High|Low)\s*:\s*(?:<=|>=|<|>|≤|≥)?\s*\d{1,5}(?:\.\d{1,6})?(?:\s*[-–—]\s*\d{1,5}(?:\.\d{1,6})?)?',
    caseSensitive: false,
  );
  final matches = category.allMatches(normalized).toList();
  if (matches.isEmpty || matches.length > 5) return null;
  if (normalized.replaceAll(category, '').trim().isNotEmpty) return null;
  final preferred = matches.where((match) {
    return RegExp(
      r'\b(?:Desirable|Normal|Optimal)\b',
      caseSensitive: false,
    ).hasMatch(match.group(0)!);
  }).toList();
  if (preferred.length != 1) return null;
  final candidate = preferred.single.group(0)!.split(':').last.trim();
  final numeric = RegExp(
    r'^(?:(?:<=|>=|<|>|≤|≥)\s*-?\d{1,5}(?:\.\d{1,6})?|-?\d{1,5}(?:\.\d{1,6})?\s*[-–—]\s*-?\d{1,5}(?:\.\d{1,6})?)$',
  );
  return numeric.hasMatch(candidate) ? candidate : null;
}

String unavailableRangeReason(ExtractedLabValue result) {
  if (result.parameterName.trim().isEmpty) {
    return 'The test name is missing from the extracted result.';
  }
  if (result.referenceRange?.trim().isNotEmpty != true) {
    return 'No lab reference range was captured for this test.';
  }
  if (result.unit?.trim().isNotEmpty != true) {
    return 'The unit is missing, so the value cannot be compared confidently.';
  }
  if (double.tryParse(result.value.trim()) == null) {
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

/// A display comparison only; the printed range may not apply to every person.
RangePosition compareWithPrintedRange(ExtractedLabValue result) {
  final rawValue = result.value.trim();
  final value = RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(rawValue)
      ? double.tryParse(rawValue)
      : null;
  final rawRange = result.referenceRange?.trim();
  final range = rawRange == null
      ? null
      : preferredPrintedRange(rawRange) ?? rawRange;
  if (result.parameterName.trim().isEmpty ||
      result.unit?.trim().isNotEmpty != true ||
      value == null ||
      !value.isFinite ||
      range == null ||
      range.isEmpty) {
    return RangePosition.unknown;
  }
  final interval = RegExp(
    r'^\s*(-?\d+(?:\.\d+)?)\s*(?:[-–—]|to)\s*(-?\d+(?:\.\d+)?)\s*$',
    caseSensitive: false,
  ).firstMatch(range);
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
    final limit = RegExp(
      r'^\s*(<=|>=|<|>|≤|≥)\s*(-?\d+(?:\.\d+)?)\s*$',
    ).firstMatch(range);
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
