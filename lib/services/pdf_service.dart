import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'i_pdf_service.dart';

class PdfService implements IPdfService {
  PdfController? _controller;
  String? _currentPdfPath;

  @override
  PdfController? get controller => _controller;

  Future<String?> getSavedPdfPath(String originalPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/cache');
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    final fileName = originalPath.split(Platform.pathSeparator).last;
    final compressedFileName = '${fileName.hashCode}.flate';
    return '${cacheDir.path}/$compressedFileName';
  }

  @override
  Future<void> loadPdf(String path) async {
    try {
      // Verificar se já existe uma versão comprimida salva
      final savedPath = await getSavedPdfPath(path);
      if (savedPath != null && await File(savedPath).exists()) {
        // Carregar versão comprimida
        final compressedData = await File(savedPath).readAsBytes();
        final decompressedData = gzip.decode(compressedData);
        final tempFile = await _createTempFile(decompressedData, path.split('/').last);
        _currentPdfPath = tempFile.path;
      } else {
        // Salvar versão comprimida para uso futuro
        final file = File(path);
        final originalData = await file.readAsBytes();
        final compressedData = gzip.encode(originalData);
        if (savedPath != null) {
          await File(savedPath).writeAsBytes(compressedData);
        }
        _currentPdfPath = path;
      }

      // Recuperar última página lida
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt('last_page_${path.hashCode}') ?? 1;

      _controller = PdfController(
        document: PdfDocument.openFile(_currentPdfPath!),
        initialPage: lastPage,
      );

      // Ouvinte para salvar a página conforme o usuário desliza
      // Nota: PdfController não tem addListener, então salvaremos manualmente no widget
    } catch (e) {
      debugPrint('Erro ao carregar PDF: $e');
      rethrow;
    }
  }

  Future<File> _createTempFile(List<int> data, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = Directory('${appDir.path}/temp');
    
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    
    final tempFile = File('${tempDir.path}/$fileName');
    return await tempFile.writeAsBytes(data);
  }

  @override
  Future<void> saveCurrentPage(String originalPath, int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_${originalPath.hashCode}', page);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _currentPdfPath = null;
  }
}