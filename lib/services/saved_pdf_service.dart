import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_pdf.dart';
import 'pdf_api_service.dart';

class SavedPdfService {
  static const String _savedPdfsKey = 'saved_pdfs';
  final PdfApiService _apiService = PdfApiService();

  Future<List<SavedPdf>> getSavedPdfs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_savedPdfsKey) ?? [];
    return jsonList.map((json) => SavedPdf.fromJson(jsonDecode(json))).toList();
  }

  Future<void> savePdfInfo(SavedPdf pdf) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPdfs = await getSavedPdfs();
    savedPdfs.add(pdf);
    final jsonList = savedPdfs.map((pdf) => jsonEncode(pdf.toJson())).toList();
    await prefs.setStringList(_savedPdfsKey, jsonList);
  }

  Future<void> deletePdf(String pdfId) async {
    debugPrint('SavedPdfService: Iniciando delete de PDF com ID: $pdfId');
    final prefs = await SharedPreferences.getInstance();
    final savedPdfs = await getSavedPdfs();

    final pdfToDelete = savedPdfs.firstWhere((pdf) => pdf.id == pdfId);
    savedPdfs.removeWhere((pdf) => pdf.id == pdfId);

    // Extract filename from URL and delete from API
    final urlParts = pdfToDelete.pdfUrl.split('/');
    final filename = urlParts.last;
    debugPrint('SavedPdfService: Extraindo filename: $filename da URL: ${pdfToDelete.pdfUrl}');
    try {
      await _apiService.deletePdf(filename);
      debugPrint('SavedPdfService: PDF deletado da API com sucesso');
    } catch (e) {
      // If API deletion fails, still remove from local storage
      // The file might have been deleted already or API might be down
      debugPrint('SavedPdfService: Aviso: Falha ao deletar PDF da API: $e');
    }

    final jsonList = savedPdfs.map((pdf) => jsonEncode(pdf.toJson())).toList();
    await prefs.setStringList(_savedPdfsKey, jsonList);
    debugPrint('SavedPdfService: PDF removido do armazenamento local');
  }
}