import 'dart:async';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class IGeminiService {
  Stream<String> streamChatResponse(String question, {String? pdfContext, Uint8List? imageBytes});
}

class GeminiService implements IGeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
      : _model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);

  @override
  Stream<String> streamChatResponse(String question, {String? pdfContext, Uint8List? imageBytes}) async* {
    final prompt = _buildPrompt(question, pdfContext);
    final input = <Content>[
      Content.text(prompt),
      if (imageBytes != null) Content.data('image/jpeg', imageBytes),
    ];
    final stream = _model.generateContentStream(input);
    await for (final res in stream) {
      final text = res.text ?? '';
      if (text.isNotEmpty) {
        yield text;
      }
    }
  }

  String _buildPrompt(String question, String? pdfContext) {
    final ctx = (pdfContext ?? '').trim();
    return [
      'Você é um assistente técnico. Responda em JSON válido no formato: ',
      '{"ordem_logica": [], "exemplos_praticos": [], "assunto": ""}.',
      'Use o contexto do PDF se fornecido. ',
      'Pergunta: ',
      question,
      if (ctx.isNotEmpty) '\nContexto:\n$ctx' else '',
    ].join('');
  }
}