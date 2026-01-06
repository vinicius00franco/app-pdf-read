import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'i_pdf_picker_service.dart';

class PdfPickerService implements IPdfPickerService {
  @override
  Future<String?> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        debugPrint('PDF selecionado: ${result.files.single.path}');
        return result.files.single.path!;
      }
      debugPrint('Nenhum arquivo selecionado');
      return null;
    } catch (e) {
      debugPrint('Erro ao selecionar PDF: $e');
      return null;
    }
  }
}