import 'package:flutter/material.dart';
import '../services/i_pdf_picker_service.dart';
import '../services/i_pdf_service.dart';
import '../services/saved_pdf_service.dart';
import '../services/pdf_api_service.dart';
import '../widgets/import_button_widget.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../models/saved_pdf.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'pdf_list_screen.dart';
import 'dart:io';

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
  String? _currentPdfUrl;
  final SavedPdfService _savedPdfService = SavedPdfService();
  final PdfApiService _apiService = PdfApiService();

  @override
  void dispose() {
    widget.pdfService.dispose();
    super.dispose();
  }

  Future<void> _pickAndLoadPdf() async {
    debugPrint('PdfReaderScreen: Iniciando seleção de PDF');
    try {
      final path = await widget.pdfPickerService.pickPdfFile();
      if (path != null) {
        debugPrint('PdfReaderScreen: PDF selecionado: $path');
        // Upload PDF to API
        final uploadResult = await _apiService.uploadPdf(File(path));
        // Use a URL completa retornada pela API
        final pdfUrl = '${_apiService.baseUrl}${uploadResult['url']}';
        debugPrint('PdfReaderScreen: URL completa do PDF: $pdfUrl');

        // Delete local cached file after upload
        try {
          await File(path).delete();
          debugPrint('PdfReaderScreen: Arquivo local deletado após upload: $path');
        } catch (e) {
          debugPrint('PdfReaderScreen: Erro ao deletar arquivo local: $e');
        }

        _currentPdfUrl = pdfUrl;
        debugPrint('PdfReaderScreen: Carregando PDF da URL: $pdfUrl');
        await widget.pdfService.loadPdf(pdfUrl);

        await _savePdfInfo(uploadResult, pdfUrl);

        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF enviado para o backend e carregado com sucesso!')),
          );
        }
      } else {
        debugPrint('PdfReaderScreen: Nenhum arquivo selecionado');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum arquivo selecionado')),
          );
        }
      }
    } catch (e) {
      debugPrint('PdfReaderScreen: Erro ao processar PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar PDF: $e')),
        );
      }
    }
  }

  Future<void> _savePdfInfo(Map<String, dynamic> uploadResult, String pdfUrl) async {
    try {
      final savedPdf = SavedPdf(
        id: uploadResult['id'],
        originalName: uploadResult['filename'],
        pdfUrl: pdfUrl,
        savedAt: DateTime.now(),
      );

      await _savedPdfService.savePdfInfo(savedPdf);
    } catch (e) {
      debugPrint('Erro ao salvar informações do PDF: $e');
    }
  }

  void _goToSavedPdfs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfListScreen(pdfService: widget.pdfService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leitor de PDF"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _goToSavedPdfs,
            tooltip: 'PDFs Salvos',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickAndLoadPdf,
            tooltip: 'Importar PDF',
          ),
        ],
      ),
      body: widget.pdfService.controller == null || _currentPdfUrl == null
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.background, AppColors.surfaceVariant],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Bem-vindo ao PDF Reader',
                        style: AppTextStyles.h1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Importe um PDF para começar',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ImportButtonWidget(onPressed: _pickAndLoadPdf),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: _goToSavedPdfs,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Ver PDFs Salvos'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : PdfViewerWidget(
              controller: widget.pdfService.controller!,
              pdfService: widget.pdfService,
              originalPath: _currentPdfUrl!,
            ),
    );
  }
}