import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../reports_repository.dart';

/// Displays an original report PDF or image fetched from the API.
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.reportsRepository,
    required this.reportId,
    required this.fileName,
    required this.onBack,
    this.reviewMode = false,
  });

  final ReportsRepository reportsRepository;
  final String reportId;
  final String fileName;
  final VoidCallback onBack;
  final bool reviewMode;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfControllerPinch? _controller;
  Uint8List? _imageBytes;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final bytes = await widget.reportsRepository.getReportFile(
        widget.reportId,
      );
      if (!mounted) return;
      final isJpeg =
          bytes.length >= 3 &&
          bytes[0] == 0xff &&
          bytes[1] == 0xd8 &&
          bytes[2] == 0xff;
      final isPng =
          bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4e &&
          bytes[3] == 0x47;
      if (isJpeg || isPng) {
        setState(() {
          _imageBytes = Uint8List.fromList(bytes);
          _loading = false;
          _errorMessage = null;
        });
        return;
      }
      final doc = await PdfDocument.openData(Uint8List.fromList(bytes));
      if (!mounted) return;
      setState(() {
        _controller = PdfControllerPinch(
          document: Future.value(doc),
          initialPage: 1,
        );
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (widget.reviewMode && !_loading && _errorMessage == null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  key: const Key('original-inspected'),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('I inspected the original'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        key: Key('pdf-viewer-loading'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading report…'),
          ],
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        key: const Key('pdf-viewer-error'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'This report\'s file is no longer available.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: widget.onBack, child: const Text('Back')),
            ],
          ),
        ),
      );
    }
    final ctrl = _controller;
    final imageBytes = _imageBytes;
    if (imageBytes != null) {
      return InteractiveViewer(
        key: const Key('image-viewer-screen'),
        minScale: 0.5,
        maxScale: 6,
        child: Center(child: Image.memory(imageBytes, fit: BoxFit.contain)),
      );
    }
    if (ctrl == null) return const SizedBox.shrink();
    return PdfViewPinch(key: const Key('pdf-viewer-screen'), controller: ctrl);
  }
}
