import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/upload_report_screen.dart';
import 'package:mobile/features/support/support_repository.dart';

class _Picker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async => FilePickerResult([
    PlatformFile(name: 'test.pdf', size: 4, path: '/tmp/test.pdf'),
  ]);
}

class _Reports extends Fake implements ReportsRepository {
  final firstUpload = Completer<UploadedReport>();
  final paths = <String>[];

  @override
  Future<UploadedReport> uploadReport(
    String filePath, {
    bool forceUploadAnyway = false,
  }) {
    paths.add(filePath);
    if (paths.length == 1) return firstUpload.future;
    return Future.value(
      const UploadedReport(
        reportId: 'report-1',
        profileId: 'profile-1',
        fileName: 'test.pdf',
        contentType: 'application/pdf',
        sizeBytes: 4,
        status: 'queued',
      ),
    );
  }
}

class _Profiles extends Fake implements ProfilesRepository {}

class _Support extends Fake implements SupportRepository {}

void main() {
  testWidgets('ambiguous upload can retry the selected file', (tester) async {
    FilePicker.platform = _Picker();
    final reports = _Reports();
    final busy = <bool>[];
    var accepted = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: UploadReportScreen(
          reportsRepository: reports,
          profilesRepository: _Profiles(),
          supportRepository: _Support(),
          activeProfileName: 'Me',
          onBack: () {},
          onComplete: () {},
          onUploadBusyChanged: busy.add,
          onUploadAccepted: () => accepted++,
        ),
      ),
    );

    await tester.tap(find.text('Pick PDF or Image'));
    await tester.pump();
    expect(find.text('Check your report'), findsOneWidget);
    expect(find.text('test.pdf'), findsOneWidget);

    await tester.tap(find.text('Add report'));
    await tester.pump();
    expect(busy, [true]);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.arrow_back),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );

    reports.firstUpload.completeError(ApiException('NETWORK_ERROR', 'Offline'));
    await tester.pump();
    expect(find.byKey(const Key('upload-retry-same-file')), findsOneWidget);
    await tester.tap(find.byKey(const Key('upload-retry-same-file')));
    await tester.pump();
    expect(reports.paths, ['/tmp/test.pdf', '/tmp/test.pdf']);
    expect(accepted, 1);
    expect(busy, [true, false, true, false]);
  });
}
