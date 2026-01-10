# Plano A: Chat LLM com Comunicação Direta (Flutter → Gemini)

Implementar sidebar de chat onde o Flutter comunica diretamente com Gemini Flash Lite, extraindo texto do PDF localmente, enviando streaming de respostas estruturadas em JSON. O backend recebe apenas persistência das respostas no PostgreSQL vetorial.

## Steps

### Flutter: Adicionar dependências Gemini + Bloc
- Atualizar pubspec.yaml com `google_generative_ai: ^0.2.2`, `flutter_bloc: ^8.1.3`, `equatable: ^2.0.5`, e **`syncfusion_flutter_pdf: ^24.1.41`** (para extração de texto), executar flutter pub get.

### Flutter: Extrair texto local ou Imagem do PDF
- Criar lib/services/pdf_extractor_service.dart usando **Syncfusion** para extrair texto de intervalos. 
- **Fallback**: Se a extração de texto falhar (PDF escaneado), usar `pdfx` para converter a página em imagem e enviar ao Gemini Vision.

### Flutter: Serviço Gemini com streaming
- Criar lib/services/gemini_service.dart com GenerativeModel, método `Stream<String> streamChatResponse(String question, {String? pdfContext, Uint8List? imageBytes})`, estruturar prompt para retornar JSON com `{ordem_logica: [], exemplos_praticos: [], assunto: ""}`.

### Flutter: Bloc para gerenciar chat
- Criar lib/features/chat/bloc/chat_bloc.dart com estados `ChatStreaming`, `ChatComplete` e **`ChatError`**.
- **Lógica de Limite**: No evento de envio, verificar se o contexto > 30k tokens; se exceder, emitir `ChatError` para disparar aviso visual.

### Flutter: Widget sidebar com dropdown + slider
- Criar lib/widgets/llm_sidebar_widget.dart com BlocProvider e BlocBuilder.
- **Flash Message**: Adicionar um widget de aviso (erro) fixado logo abaixo do header da sidebar, visível apenas quando o estado for `ChatError`.

### Flutter: Integrar sidebar no PdfReaderScreen
- Modificar pdf_reader_screen.dart para usar Row com `Expanded(flex: 7, child: PdfViewerWidget)` e `Expanded(flex: 3, child: LLMSidebarWidget)`, passando os bytes/documento do PDF.

### Flutter: Serviço de persistência
- Criar lib/services/llm_persistence_service.dart com método `persistResponse` para salvar o JSON final no backend após a conclusão do stream.

### Backend: Docker Compose + PostgreSQL com pgvector
- Criar docker-compose.yml com serviço PostgreSQL 15 e extensão pgvector, variáveis de ambiente, expor porta 5432.

### Backend: Configurar conexão PostgreSQL + modelos
- Criar backend/app/db.py e modelos com tabela `llm_responses` contendo: id, pdf_id, question, answer, subject, embedding (vector).

### Backend: Endpoint para persistir respostas LLM
- Criar backend/app/routes/llm_routes.py com POST /api/llm/persist, gerar embedding no server-side e salvar no PostgreSQL.

## Further Considerations

### Segurança da API Key
- A chave do Gemini ficará na env do flutter (usar `--dart-define` para segurança).

### Extração de texto (Ajustado)
- Substituído `pdfx` por **Syncfusion** para extração de texto confiável. Implementado fallback para envio de imagem da página caso o PDF não possua camada de texto.

### Tamanho do contexto (Ajustado)
- Adicionado verificador de 30k tokens. Caso exceda, uma **flash message de erro** é exibida abaixo do header da sidebar para orientar o usuário a reduzir o intervalo de páginas.