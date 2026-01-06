import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../services/i_pdf_service.dart';

class PdfViewerWidget extends StatefulWidget {
  final PdfController controller;
  final IPdfService pdfService;
  final String originalPath;

  const PdfViewerWidget({
    super.key,
    required this.controller,
    required this.pdfService,
    required this.originalPath,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    debugPrint('PdfViewerWidget: initState chamado');
    debugPrint('PdfViewerWidget: controller.pagesCount = ${widget.controller.pagesCount}');

    // Tentar obter o total de páginas de forma assíncrona
    _initializeTotalPages();
  }

  Future<void> _initializeTotalPages() async {
    try {
      // Aguardar um pouco para o documento carregar
      await Future.delayed(const Duration(milliseconds: 100));

      final pages = widget.controller.pagesCount;
      debugPrint('PdfViewerWidget: Após delay, pagesCount = $pages');

      if (pages != null && pages > 0) {
        setState(() {
          totalPages = pages;
        });
        debugPrint('PdfViewerWidget: totalPages atualizado para $totalPages');
      } else {
        debugPrint('PdfViewerWidget: pagesCount ainda é null ou 0, tentando novamente...');
        // Tentar novamente após mais tempo
        await Future.delayed(const Duration(milliseconds: 500));
        final retryPages = widget.controller.pagesCount;
        debugPrint('PdfViewerWidget: Após retry, pagesCount = $retryPages');

        if (retryPages != null && retryPages > 0) {
          setState(() {
            totalPages = retryPages;
          });
          debugPrint('PdfViewerWidget: totalPages atualizado após retry para $totalPages');
        } else {
          debugPrint('PdfViewerWidget: Falhou em obter pagesCount mesmo após retry');
        }
      }
    } catch (e) {
      debugPrint('PdfViewerWidget: Erro ao inicializar totalPages: $e');
    }
  }

  void _onPageChanged(int? page) {
    debugPrint('PdfViewerWidget: _onPageChanged chamado com page = $page');
    setState(() {
      currentPage = page ?? 1;
    });
    // Salvar página atual
    widget.pdfService.saveCurrentPage(widget.originalPath, currentPage);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('PdfViewerWidget: build chamado - currentPage: $currentPage, totalPages: $totalPages');
    return Column(
      children: [
        Expanded(
          child: PdfView(
            controller: widget.controller,
            scrollDirection: Axis.horizontal,
            onPageChanged: _onPageChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Página $currentPage de $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        LinearProgressIndicator(
          value: totalPages > 0 ? currentPage / totalPages : 0,
        ),
      ],
    );
  }
}