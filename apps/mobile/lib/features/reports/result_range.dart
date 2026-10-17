import 'reports_repository.dart';

enum RangePosition { below, within, above, unknown }

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
  return 'The extracted value, printed range, or lab flag needs checking in the original report.';
}

/// A display comparison only; the printed range may not apply to every person.
RangePosition compareWithPrintedRange(ExtractedLabValue result) {
  final rawValue = result.value.trim();
  final value = RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(rawValue)
      ? double.tryParse(rawValue)
      : null;
  final range = result.referenceRange?.trim();
  if (result.parameterName.trim().isEmpty ||
      result.unit?.trim().isNotEmpty != true ||
      value == null ||
      !value.isFinite ||
      range == null ||
      range.isEmpty) {
    return RangePosition.unknown;
  }
  final match = RegExp(
    r'^\s*(-?\d+(?:\.\d+)?)\s*[-–]\s*(-?\d+(?:\.\d+)?)\s*$',
  ).firstMatch(range);
  if (match == null) return RangePosition.unknown;
  final low = double.tryParse(match.group(1)!);
  final high = double.tryParse(match.group(2)!);
  if (low == null ||
      high == null ||
      !low.isFinite ||
      !high.isFinite ||
      low > high) {
    return RangePosition.unknown;
  }
  final position = value < low
      ? RangePosition.below
      : value > high
      ? RangePosition.above
      : RangePosition.within;
  if (result.isAbnormal != null &&
      result.isAbnormal != (position != RangePosition.within)) {
    return RangePosition.unknown;
  }
  return position;
}
