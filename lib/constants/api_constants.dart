/// Configurações da API para o aplicativo Flutter
/// Centraliza todas as rotas e URLs para facilitar manutenção

// Base URL da API - ALTERE ESTA CONSTANTE PARA O SEU AMBIENTE
const String baseUrl = 'http://192.168.15.2:8000'; // IP local da máquina host

class ApiEndpoints {
  // Sistema
  static const String systemInfo = '/api/system/';
  static const String healthCheck = '/api/system/health';

  // PDFs
  static const String uploadPdf = '/api/pdfs/upload';
  static const String downloadPdf = '/api/pdfs/';
  static const String deletePdf = '/api/pdfs/';
  static const String listPdfs = '/api/pdfs/';

  // Arquivos estáticos
  static const String staticPdf = '/pdfs/';

  // URLs completas
  static String get fullBaseUrl => baseUrl;

  static String get systemInfoUrl => '$baseUrl$systemInfo';
  static String get healthCheckUrl => '$baseUrl$healthCheck';
  static String get uploadPdfUrl => '$baseUrl$uploadPdf';
  static String get listPdfsUrl => '$baseUrl$listPdfs';
  static String downloadPdfUrl(String filename) => '$baseUrl$downloadPdf$filename';
  static String deletePdfUrl(String filename) => '$baseUrl$deletePdf$filename';
  static String staticPdfUrl(String filename) => '$baseUrl$staticPdf$filename';
}