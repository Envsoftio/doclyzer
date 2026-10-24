import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/theme/app_theme.dart';

/// Converts checked photos into a single ordered PDF off the UI thread.
Future<Uint8List> buildReportPdf(List<Uint8List> images) async {
  final document = pw.Document(compress: true);
  for (final bytes in images) {
    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (_) {
      throw const FormatException('Unreadable image');
    }
    if (decoded == null) throw const FormatException('Unreadable image');
    final oriented = img.bakeOrientation(decoded);
    final pageBytes = img.encodeJpg(oriented, quality: 88);
    final aspect = oriented.width / oriented.height;
    final pageWidth = PdfPageFormat.a4.width;
    final pageHeight = pageWidth / aspect;
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, pageHeight),
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Image(
          pw.MemoryImage(pageBytes),
          width: pageWidth,
          height: pageHeight,
          fit: pw.BoxFit.fill,
        ),
      ),
    );
  }
  return document.save();
}

/// Reviews camera/gallery pages before they enter the existing report upload.
/// The result is a single PDF, so processing and duplicate detection keep their
/// existing behavior.
class ReportPagesScreen extends StatefulWidget {
  const ReportPagesScreen({
    super.key,
    required this.profileName,
    required this.initialPaths,
    this.picker,
  });

  final String profileName;
  final List<String> initialPaths;
  final ImagePicker? picker;

  @override
  State<ReportPagesScreen> createState() => _ReportPagesScreenState();
}

class _ReportPagesScreenState extends State<ReportPagesScreen> {
  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  late final List<String> _pages = [...widget.initialPaths];
  bool _reordering = false;
  bool _preparing = false;
  String? _error;

  Future<void> _add(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final images = await _picker.pickMultiImage(imageQuality: 95);
        if (mounted && images.isNotEmpty) {
          setState(() => _pages.addAll(images.map((image) => image.path)));
        }
      } else {
        final image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 95,
        );
        if (mounted && image != null) setState(() => _pages.add(image.path));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not open photos or camera.');
    }
  }

  Future<void> _retake(int index) async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );
      if (mounted && image != null) setState(() => _pages[index] = image.path);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not open camera.');
    }
  }

  Future<void> _adjust(int index) async {
    final replacement = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => AdjustReportPageScreen(
          path: _pages[index],
          profileName: widget.profileName,
          pageNumber: index + 1,
        ),
      ),
    );
    if (mounted && replacement != null) {
      setState(() => _pages[index] = replacement);
    }
  }

  Future<void> _prepare() async {
    if (_pages.isEmpty || _preparing) return;
    setState(() {
      _preparing = true;
      _error = null;
    });
    try {
      final pages = await Future.wait(
        _pages.map((path) => File(path).readAsBytes()),
      );
      final pdfBytes = await compute(buildReportPdf, pages);
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/doclyzer_report_${DateTime.now().microsecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(pdfBytes, flush: true);
      if (mounted) Navigator.of(context).pop(file.path);
    } catch (_) {
      if (mounted) {
        setState(() {
          _preparing = false;
          _error =
              'Could not prepare these pages. Retake an unreadable page and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your report pages')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              key: const Key('analyze-report-pages'),
              onPressed: _preparing || _pages.isEmpty ? null : _prepare,
              child: _preparing
                  ? const CircularProgressIndicator()
                  : Text(
                      'Analyze ${_pages.length} ${_pages.length == 1 ? 'page' : 'pages'}',
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              _reordering
                  ? 'Drag pages into the order shown in your report'
                  : 'Check every page before analyzing',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(widget.profileName),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_pages.length} ${_pages.length == 1 ? 'page' : 'pages'} added',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: _pages.length < 2
                    ? null
                    : () => setState(() => _reordering = !_reordering),
                child: Text(_reordering ? 'Done' : 'Reorder'),
              ),
            ],
          ),
          Text(
            'Keep pages in the same order as the report.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          if (_reordering)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pages.length,
              onReorderItem: (from, to) => setState(() {
                final page = _pages.removeAt(from);
                _pages.insert(to, page);
              }),
              itemBuilder: (context, index) =>
                  _pageCard(index, key: ValueKey(_pages[index])),
            )
          else
            for (var index = 0; index < _pages.length; index++)
              _pageCard(index, key: ValueKey(_pages[index])),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _add(ImageSource.camera),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add another page'),
          ),
          TextButton.icon(
            onPressed: () => _add(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose pages from gallery'),
          ),
        ],
      ),
    );
  }

  Widget _pageCard(int index, {required Key key}) => Padding(
    key: key,
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(_pages[index]),
                width: 68,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  width: 68,
                  height: 88,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Page ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton(
                    onPressed: () => _adjust(index),
                    child: const Text('Adjust page'),
                  ),
                  TextButton(
                    onPressed: () => _retake(index),
                    child: const Text('Retake'),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove page ${index + 1}',
              onPressed: () => setState(() => _pages.removeAt(index)),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    ),
  );
}

class AdjustReportPageScreen extends StatefulWidget {
  const AdjustReportPageScreen({
    super.key,
    required this.path,
    required this.profileName,
    required this.pageNumber,
  });
  final String path;
  final String profileName;
  final int pageNumber;

  @override
  State<AdjustReportPageScreen> createState() => _AdjustReportPageScreenState();
}

class _AdjustReportPageScreenState extends State<AdjustReportPageScreen> {
  late String _path = widget.path;
  int _rotation = 0;
  double _crop = 0;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final original = img.decodeImage(await File(_path).readAsBytes());
      if (original == null) throw const FormatException('Unreadable image');
      var result = img.bakeOrientation(original);
      if (_rotation != 0) result = img.copyRotate(result, angle: _rotation);
      if (_crop > 0) {
        final dx = (result.width * _crop).round();
        final dy = (result.height * _crop).round();
        result = img.copyCrop(
          result,
          x: dx,
          y: dy,
          width: result.width - dx * 2,
          height: result.height - dy * 2,
        );
      }
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/doclyzer_page_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(img.encodeJpg(result, quality: 92), flush: true);
      if (mounted) Navigator.of(context).pop(file.path);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not adjust this page.';
        });
      }
    }
  }

  Future<void> _retake() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );
      if (mounted && image != null) {
        setState(() {
          _path = image.path;
          _rotation = 0;
          _crop = 0;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not open camera.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Adjust page')),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const CircularProgressIndicator()
                : const Text('Use adjusted page'),
          ),
          TextButton(
            onPressed: () => setState(() {
              _rotation = 0;
              _crop = 0;
            }),
            child: const Text('Reset changes'),
          ),
        ],
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Keep every result inside the corners.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Text('${widget.profileName} · Page ${widget.pageNumber}'),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: .75,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRect(
              child: Transform.scale(
                scale: 1 / (1 - 2 * _crop),
                child: Transform.rotate(
                  angle: _rotation * 3.141592653589793 / 180,
                  child: Image.file(File(_path), fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Crop edges: ${(_crop * 100).round()}%'),
        Slider(
          value: _crop,
          min: 0,
          max: .2,
          divisions: 20,
          label: '${(_crop * 100).round()}%',
          onChanged: (value) => setState(() => _crop = value),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _rotation = (_rotation + 90) % 360),
          icon: const Icon(Icons.rotate_right),
          label: const Text('Rotate'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _retake,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Retake'),
        ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
  );
}
