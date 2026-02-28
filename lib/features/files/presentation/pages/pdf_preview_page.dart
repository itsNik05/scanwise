import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfPreviewPage extends StatefulWidget {
  final String path;
  final String name;

  const PdfPreviewPage({
    super.key,
    required this.path,
    required this.name,
  });

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.path),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: PdfView(
        controller: _pdfController,
      ),
    );
  }
}