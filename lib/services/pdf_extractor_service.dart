import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

abstract class IPdfExtractorService {
  Future<String> extractTextFromUrl(String url, {List<int>? pages});
  Future<String> extractTextFromBytes(Uint8List bytes, {List<int>? pages});
  Future<Uint8List?> renderPageImage(Uint8List bytes, int page);
}

class PdfExtractorService implements IPdfExtractorService {
  final Dio _dio;

  PdfExtractorService({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<String> extractTextFromUrl(String url, {List<int>? pages}) async {
    final bytes = await _fetch(url);
    return extractTextFromBytes(bytes, pages: pages);
  }

  @override
  Future<String> extractTextFromBytes(Uint8List bytes, {List<int>? pages}) async {
    final doc = PdfDocument(inputBytes: bytes);
    final buffer = StringBuffer();
    try {
      if (pages == null || pages.isEmpty) {
        for (var i = 0; i < doc.pages.count; i++) {
          final extractor = PdfTextExtractor(doc);
          buffer.write(extractor.extractText(startPageIndex: i, endPageIndex: i));
          buffer.write('\n');
        }
      } else {
        final extractor = PdfTextExtractor(doc);
        for (final p in pages) {
          final idx = p - 1;
          if (idx >= 0 && idx < doc.pages.count) {
            buffer.write(extractor.extractText(startPageIndex: idx, endPageIndex: idx));
            buffer.write('\n');
          }
        }
      }
      return buffer.toString().trim();
    } finally {
      doc.dispose();
    }
  }

  @override
  Future<Uint8List?> renderPageImage(Uint8List bytes, int page) async {
    return null;
  }

  Future<Uint8List> _fetch(String url) async {
    final res = await _dio.get(url, options: Options(responseType: ResponseType.bytes));
    if (res.statusCode == 200) {
      return Uint8List.fromList(res.data);
    }
    throw Exception('Failed to fetch PDF');
  }
}