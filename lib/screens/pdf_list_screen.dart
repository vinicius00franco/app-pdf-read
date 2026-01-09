import 'package:flutter/material.dart';
import '../models/saved_pdf.dart';
import '../services/saved_pdf_service.dart';
import '../services/i_pdf_service.dart';
import '../widgets/pdf_viewer_widget.dart';

class PdfListScreen extends StatefulWidget {
  final IPdfService pdfService;

  const PdfListScreen({super.key, required this.pdfService});

  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  final SavedPdfService _savedPdfService = SavedPdfService();
  List<SavedPdf> _savedPdfs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPdfs();
  }

  Future<void> _loadSavedPdfs() async {
    setState(() => _isLoading = true);
    try {
      final pdfs = await _savedPdfService.getSavedPdfs();
      setState(() {
        _savedPdfs = pdfs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar PDFs: $e')),
        );
      }
    }
  }

  Future<void> _deletePdf(SavedPdf pdf) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${pdf.originalName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _savedPdfService.deletePdf(pdf.id);
        await _loadSavedPdfs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF excluído com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir PDF: $e')),
          );
        }
      }
    }
  }

  Future<void> _openPdf(SavedPdf pdf) async {
    try {
      await widget.pdfService.loadPdf(pdf.pdfUrl);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(pdf.originalName),
              ),
              body: PdfViewerWidget(
                controller: widget.pdfService.controller!,
                pdfService: widget.pdfService,
                originalPath: pdf.pdfUrl,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDFs Salvos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedPdfs.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum PDF salvo',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _savedPdfs.length,
                  itemBuilder: (context, index) {
                    final pdf = _savedPdfs[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: Text(pdf.originalName),
                        subtitle: Text(
                          'Salvo em: ${pdf.savedAt.day}/${pdf.savedAt.month}/${pdf.savedAt.year}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _openPdf(pdf),
                              tooltip: 'Abrir PDF',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePdf(pdf),
                              tooltip: 'Excluir PDF',
                            ),
                          ],
                        ),
                        onTap: () => _openPdf(pdf),
                      ),
                    );
                  },
                ),
    );
  }
}