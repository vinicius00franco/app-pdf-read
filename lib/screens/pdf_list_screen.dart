import 'package:flutter/material.dart';
import '../models/saved_pdf.dart';
import '../services/saved_pdf_service.dart';
import '../services/i_pdf_service.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/llm_sidebar_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar PDFs: $e')));
      }
    }
  }

  Future<void> _deletePdf(SavedPdf pdf) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogRadius),
        ),
        title: Text('Confirmar exclusão', style: AppTextStyles.h3),
        content: Text(
          'Deseja excluir "${pdf.originalName}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao excluir PDF: $e')));
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
            builder: (context) => _PdfViewerPage(
              pdfService: widget.pdfService,
              pdfUrl: pdf.pdfUrl,
              fileName: pdf.originalName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao abrir PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDFs Salvos')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _savedPdfs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Nenhum PDF salvo',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Importe um PDF para começar',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _savedPdfs.length,
              itemBuilder: (context, index) {
                final pdf = _savedPdfs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: InkWell(
                    onTap: () => _openPdf(pdf),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.pdfIcon.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.sm,
                              ),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf,
                              color: AppColors.pdfIcon,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pdf.originalName,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Salvo em: ${pdf.savedAt.day.toString().padLeft(2, '0')}/${pdf.savedAt.month.toString().padLeft(2, '0')}/${pdf.savedAt.year}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined),
                            onPressed: () => _openPdf(pdf),
                            tooltip: 'Abrir PDF',
                            color: AppColors.primary,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deletePdf(pdf),
                            tooltip: 'Excluir PDF',
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _PdfViewerPage extends StatefulWidget {
  final IPdfService pdfService;
  final String pdfUrl;
  final String fileName;

  const _PdfViewerPage({
    required this.pdfService,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  State<_PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<_PdfViewerPage> {
  bool _isSidebarOpen = false;
  bool _showingChat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.fileName)),
      body: Stack(
        children: [
          // PDF Viewer (ocupa tela toda menos o indicador)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 50,
            child: PdfViewerWidget(
              controller: widget.pdfService.controller!,
              pdfService: widget.pdfService,
              originalPath: widget.pdfUrl,
            ),
          ),
          // Indicador lateral fixo
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 50,
            child: GestureDetector(
              onTap: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
              child: Container(
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: _isSidebarOpen ? 0 : 3,
                      child: Icon(
                        _isSidebarOpen ? Icons.close : Icons.chat,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    if (!_isSidebarOpen) ...[
                      const SizedBox(height: 8),
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'CHAT',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Sidebar expansível
          // AnimatedPositioned(
          //   duration: const Duration(milliseconds: 300),
          //   curve: Curves.easeInOut,
          //   right: _isSidebarOpen
          //       ? 50
          //       : -MediaQuery.of(context).size.width * 0.8,
          //   top: 0,
          //   bottom: 0,
          //   width: MediaQuery.of(context).size.width * 0.8,
          //   child: Material(
          //     elevation: 16,
          //     child: Column(
          //       children: [
          //         // Conteúdo
          //         Expanded(
          //           child: LLMSidebarWidget(
          //             pdfUrl: widget.pdfUrl,
          //             apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
