# Plano A: Chat LLM com Comunicação Direta (Flutter → Gemini)

Implementar sidebar de chat onde o Flutter comunica diretamente com Gemini Flash Lite, extraindo texto do PDF localmente, enviando streaming de respostas estruturadas em JSON. O backend recebe apenas persistência das respostas no PostgreSQL vetorial.

## Steps

### Flutter: Adicionar dependências Gemini + Bloc
- Atualizar pubspec.yaml com google_generative_ai: ^0.2.2, flutter_bloc: ^8.1.3, equatable: ^2.0.5, executar flutter pub get

### Flutter: Extrair texto local do PDF
- Criar lib/services/pdf_text_extractor_service.dart usando pdfx para extrair texto de páginas específicas ou intervalos do PdfDocument já carregado, retornar Future<String> extractText(int startPage, int endPage)

### Flutter: Serviço Gemini com streaming
- Criar lib/services/gemini_service.dart com GenerativeModel, método Stream<String> streamChatResponse(String question, String pdfContext), preprocessar prompt (remover espaços/quebras desnecessários), estruturar prompt para retornar JSON com {ordem_logica: [], exemplos_praticos: [], assunto: ""}, acumular chunks e fazer yield incremental

### Flutter: Bloc para gerenciar chat
- Criar lib/features/chat/bloc/chat_bloc.dart, chat_event.dart com SendQuestionEvent, chat_state.dart com estados ChatStreaming, ChatComplete, usar emit.forEach para escutar stream do Gemini, acumular resposta completa para persistência

### Flutter: Widget sidebar com dropdown + slider
- Criar lib/widgets/llm_sidebar_widget.dart com BlocProvider e BlocBuilder<ChatBloc, ChatState>, dropdown para selecionar "Página Atual" ou "Intervalo", slider para seleção de páginas, TextField para pergunta, ListView para mensagens, exibir resposta estruturada (ordem lógica → exemplos práticos), botão enviar dispara SendQuestionEvent

### Flutter: Integrar sidebar no PdfReaderScreen
- Modificar pdf_reader_screen.dart para usar Row com Expanded(flex: 7, child: PdfViewerWidget) e Expanded(flex: 3, child: LLMSidebarWidget), passar _currentPage, _totalPages, pdfDocument como parâmetros, instanciar ChatBloc com GeminiService via BlocProvider

### Flutter: Serviço de persistência
- Criar lib/services/llm_persistence_service.dart com método Future<void> persistResponse(String question, String answer, String subject, String pdfId) que chama endpoint backend apenas para salvar no PostgreSQL vetorial

### Backend: Docker Compose + PostgreSQL com pgvector
- Criar docker-compose.yml com serviço PostgreSQL 15 e extensão pgvector, variáveis de ambiente (POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB), expor porta 5432, criar volume para persistência

### Backend: Configurar conexão PostgreSQL + modelos
- Criar backend/app/db.py com SQLAlchemy async engine (asyncpg), criar backend/app/models/llm_response_model.py com tabela llm_responses contendo campos: id, pdf_id, question, answer, subject (extraído do JSON), embedding (vector), created_at

### Backend: Endpoint para persistir respostas LLM
- Criar backend/app/routes/llm_routes.py com POST /api/llm/persist, receber payload (question, answer, subject, pdf_id), gerar embedding usando Google Generative AI Embeddings, salvar no PostgreSQL com vector, retornar confirmação

## Further Considerations

### Segurança da API Key
- A chave do Gemini ficará na env do flutter (usar `--dart-define` para segurança).

### Extração de texto (Ajustado)
- Substituído `pdfx` por **Syncfusion** para extração de texto confiável. Implementado fallback para envio de imagem da página caso o PDF não possua camada de texto.

### Tamanho do contexto (Ajustado)
- Adicionado verificador de 30k tokens. Caso exceda, uma **flash message de erro** é exibida abaixo do header da sidebar para orientar o usuário a reduzir o intervalo de páginas.
