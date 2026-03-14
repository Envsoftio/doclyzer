import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../reports_repository.dart';

/// Displays a report PDF fetched from the API.
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.reportsRepository,
    required this.reportId,
    required this.fileName,
    required this.onBack,
  });

  final ReportsRepository reportsRepository;
  final String reportId;
  final String fileName;
  final VoidCallback onBack;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfControllerPinch? _controller;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final bytes = await widget.reportsRepository.getReportFile(widget.reportId);
      if (!mounted) return;
      final doc = await PdfDocument.openData(Uint8List.fromList(bytes));
      if (!mounted) return;
      setState(() {
        _controller = PdfControllerPinch(
          document: doc,
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
      body: _buildBody(),
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
            Text('Loading PDF…'),
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
              FilledButton(
                onPressed: widget.onBack,
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }
    final ctrl = _controller;
    if (ctrl == null) return const SizedBox.shrink();
    return PdfViewPinch(
      key: const Key('pdf-viewer-screen'),
      controller: ctrl,
    );
  }
}
