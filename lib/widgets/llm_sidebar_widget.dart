import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/chat/bloc/chat_bloc.dart';
import '../services/gemini_service.dart';
import '../services/pdf_extractor_service.dart';
import '../services/llm_persistence_service.dart';

class LLMSidebarWidget extends StatefulWidget {
  final String pdfUrl;
  final String apiKey;
  const LLMSidebarWidget({
    super.key,
    required this.pdfUrl,
    required this.apiKey,
  });

  @override
  State<LLMSidebarWidget> createState() => _LLMSidebarWidgetState();
}

class _LLMSidebarWidgetState extends State<LLMSidebarWidget> {
  final _qController = TextEditingController();
  final _extractor = PdfExtractorService();
  RangeValues _range = const RangeValues(1, 5);
  String? _context;

  /// Extrai o texto do PDF para ser usado como contexto para a IA.
  /// Atualmente extrai o conteúdo completo da URL do PDF.
  Future<void> _extractContext() async {
    final text = await _extractor.extractTextFromUrl(widget.pdfUrl);
    setState(() => _context = text);
  }

  @override
  void initState() {
    super.initState();
    _extractContext();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ChatBloc(GeminiService(widget.apiKey));
    final persistence = LlmPersistenceService();
    return BlocProvider(
      create: (_) => bloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Chat LLM',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatError) {
                return Container(
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Seção de Entrada: Campo de texto e Sliders de configuração.
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _qController,
                  decoration: const InputDecoration(
                    labelText: 'Pergunte ao LLM',
                    hintText: 'Ex: Resuma este documento',
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Intervalo de páginas (Contexto)'),
                    RangeSlider(
                      values: _range,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      onChanged: (v) => setState(() => _range = v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Dispara o evento de envio para o Bloc, passando a pergunta e o texto extraído.
                    context.read<ChatBloc>().add(
                      SendQuestion(_qController.text, context: _context),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar'),
                ),
              ],
            ),
          ),
          // Seção de Resposta: Exibe o streaming do texto vindo da IA.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: BlocListener<ChatBloc, ChatState>(
                listenWhen: (prev, curr) => curr is ChatComplete,
                listener: (context, state) async {
                  if (state is ChatComplete) {
                    // Salva a interação no histórico local após a conclusão.
                    await persistence.persistResponse({
                      'pdf_id': widget.pdfUrl,
                      'question': _qController.text,
                      'answer': state.full,
                      'subject': '',
                    });
                  }
                },
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    // Diferencia visualmente entre o carregamento (streaming) e o resultado final.
                    final text = state is ChatStreaming
                        ? state.partial
                        : state is ChatComplete
                        ? state.full
                        : '';

                    // Se o texto estiver vazio e não houver erro, podemos estar aguardando a primeira resposta
                    if (text.isEmpty &&
                        state is! ChatError &&
                        _qController.text.isNotEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      child: SelectableText(
                        text,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
