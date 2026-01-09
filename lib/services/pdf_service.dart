import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'i_pdf_service.dart';

class PdfService implements IPdfService {
  PdfController? _controller;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  @override
  PdfController? get controller => _controller;

  @override
  Future<String?> getSavedPdfPath(String originalPath) async {
    // This method is no longer used for file paths, but kept for compatibility
    // Now we return the URL directly
    return null;
  }

  @override
  Future<void> loadPdf(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt('last_page_${url.hashCode}') ?? 1;

      _controller = PdfController(
        document: PdfDocument.openData(await _fetchPdfData(url)),
        initialPage: lastPage,
      );
    } catch (e) {
      debugPrint('Erro ao carregar PDF: $e');
      rethrow;
    }
  }

  Future<Uint8List> _fetchPdfData(String url) async {
    final response = await _dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList(response.data);
    } else {
      throw Exception('Failed to load PDF from URL: ${response.statusCode}');
    }
  }

  @override
  Future<void> saveCurrentPage(String url, int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_${url.hashCode}', page);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}