import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
        File arquivoOriginal = File(result.files.single.path!);
        String nomeArquivo = result.files.single.name;

        // Verificar se o arquivo original tem conteúdo
        final originalLength = await arquivoOriginal.length();
        debugPrint('Arquivo original tamanho: $originalLength bytes');

        // Pega o diretório interno do app
        final diretorioApp = await getApplicationDocumentsDirectory();

        // Define o caminho de destino
        String caminhoNovo = p.join(diretorioApp.path, nomeArquivo);

        // Efetua a cópia física
        File arquivoCopiado = await arquivoOriginal.copy(caminhoNovo);

        // Verificar se a cópia foi bem-sucedida
        final copiedLength = await arquivoCopiado.length();
        debugPrint('Arquivo copiado tamanho: $copiedLength bytes');

        if (copiedLength == 0) {
          debugPrint('Erro: Arquivo copiado está vazio');
          return null;
        }

        debugPrint('PDF selecionado e copiado: ${arquivoCopiado.path}');
        return arquivoCopiado.path;
      }
      debugPrint('Nenhum arquivo selecionado');
      return null;
    } catch (e) {
      debugPrint('Erro ao selecionar e copiar PDF: $e');
      return null;
    }
  }
}