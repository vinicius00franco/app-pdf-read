import 'package:flutter/material.dart';
import '../services/i_pdf_picker_service.dart';
import '../services/i_pdf_service.dart';
import '../widgets/import_button_widget.dart';
import '../widgets/pdf_viewer_widget.dart';

class PdfReaderScreen extends StatefulWidget {
  final IPdfPickerService pdfPickerService;
  final IPdfService pdfService;

  const PdfReaderScreen({
    super.key,
    required this.pdfPickerService,
    required this.pdfService,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  String? _currentPdfPath;

  @override
  void dispose() {
    widget.pdfService.dispose();
    super.dispose();
  }

  Future<void> _pickAndLoadPdf() async {
    try {
      final path = await widget.pdfPickerService.pickPdfFile();
      if (path != null) {
        _currentPdfPath = path;
        await widget.pdfService.loadPdf(path);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF carregado com sucesso!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum arquivo selecionado')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leitor de PDF")),
      body: widget.pdfService.controller == null || _currentPdfPath == null
          ? Center(
              child: ImportButtonWidget(onPressed: _pickAndLoadPdf),
            )
          : PdfViewerWidget(
              controller: widget.pdfService.controller!,
              pdfService: widget.pdfService,
              originalPath: _currentPdfPath!,
            ),
    );
  }
}