import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mobile/features/reports/screens/report_pages_screen.dart';

void main() {
  test('reviewed photos become one ordered two-page PDF', () async {
    Uint8List page(int color) {
      final image = img.Image(width: 32, height: 48);
      img.fill(image, color: img.ColorRgb8(color, 40, 60));
      return Uint8List.fromList(img.encodePng(image));
    }

    final onePage = await buildReportPdf([page(10)]);
    final twoPages = await buildReportPdf([page(10), page(200)]);
    expect(latin1.decode(twoPages.take(8).toList()), startsWith('%PDF-'));
    expect(twoPages.length, greaterThan(onePage.length));
    expect(
      RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(twoPages)).length,
      2,
    );
  });

  test('unreadable photos cannot be sent as a report', () async {
    await expectLater(
      buildReportPdf([
        Uint8List.fromList([1, 2, 3]),
      ]),
      throwsFormatException,
    );
  });
}
