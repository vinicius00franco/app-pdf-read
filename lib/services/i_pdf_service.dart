import 'package:pdfx/pdfx.dart';

abstract class IPdfService {
  PdfController? get controller;
  Future<void> loadPdf(String path);
  Future<void> saveCurrentPage(String originalPath, int page);
  Future<String?> getSavedPdfPath(String originalPath);
  void dispose();
}