import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart' as api;

class PdfApiService {
  // Base URL obtida do arquivo de constantes
  static String get _baseUrl => api.baseUrl;

  // Expor baseUrl para uso externo
  String get baseUrl => _baseUrl;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<Map<String, dynamic>> uploadPdf(File pdfFile) async {
    try {
      debugPrint('PdfApiService: Iniciando upload de PDF: ${pdfFile.path}');
      debugPrint('PdfApiService: Base URL: $_baseUrl');
      
      // Verificar se o arquivo existe e tem conteúdo
      if (!await pdfFile.exists()) {
        throw Exception('Arquivo não existe: ${pdfFile.path}');
      }
      final fileLength = await pdfFile.length();
      debugPrint('PdfApiService: Tamanho do arquivo: $fileLength bytes');
      if (fileLength == 0) {
        throw Exception('Arquivo está vazio: ${pdfFile.path}');
      }
      
      // Ler os bytes do arquivo
      final fileBytes = await pdfFile.readAsBytes();
      debugPrint('PdfApiService: Bytes lidos: ${fileBytes.length}');
      
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: pdfFile.path.split(Platform.pathSeparator).last,
        ),
      });

      final url = api.ApiEndpoints.uploadPdf;
      debugPrint('PdfApiService: Fazendo POST para: $_baseUrl$url');
      debugPrint('PdfApiService: Testando conexão com backend...');
      
      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200) {
        debugPrint('PdfApiService: Upload bem-sucedido: ${response.data}');
        return response.data;
      } else {
        debugPrint('PdfApiService: Erro no upload: ${response.statusCode}');
        throw Exception('Failed to upload PDF: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('PdfApiService: DioException - Tipo: ${e.type}');
      debugPrint('PdfApiService: DioException - Mensagem: ${e.message}');
      debugPrint('PdfApiService: DioException - Response: ${e.response}');
      rethrow;
    } catch (e) {
      debugPrint('PdfApiService: Erro inesperado: $e');
      rethrow;
    }
  }

  Future<void> deletePdf(String filename) async {
    debugPrint('PdfApiService: Iniciando delete de PDF: $filename');
    final url = '${api.ApiEndpoints.deletePdf}$filename';
    debugPrint('PdfApiService: Fazendo DELETE para: $_baseUrl$url');
    final response = await _dio.delete(url);

    if (response.statusCode != 200) {
      debugPrint('PdfApiService: Erro no delete: ${response.statusCode}');
      throw Exception('Failed to delete PDF: ${response.statusCode}');
    } else {
      debugPrint('PdfApiService: Delete bem-sucedido');
    }
  }

  String getPdfUrl(String filename) {
    final url = _baseUrl + api.ApiEndpoints.staticPdf + filename;
    debugPrint('PdfApiService: URL do PDF gerada: $url');
    return url;
  }
}