# Plano B: Chat LLM com Backend Intermediário (Flutter → Backend → Gemini)

Implementar sidebar de chat onde Flutter chama backend FastAPI que gerencia comunicação com Gemini Flash Lite via LangChain, extrai texto do PDF no servidor, usa RAG com PostgreSQL vetorial, e retorna streaming SSE para Flutter com respostas estruturadas.

## Steps

### Backend: Docker Compose + PostgreSQL com pgvector
- Criar docker-compose.yml com serviços: PostgreSQL 15 (extensão pgvector), FastAPI backend, variáveis de ambiente (POSTGRES_*, GOOGLE_API_KEY), networks compartilhadas, volumes para assets/ e database

### Backend: Adicionar dependências LangChain + PDF
- Atualizar requirements.txt com langchain==0.1.0, langchain-google-genai==0.0.6, pdfplumber==0.10.3, sse-starlette==1.8.2, pgvector==0.2.4, psycopg2-binary==2.9.9, python-dotenv==1.0.0, criar backend/.env com GOOGLE_API_KEY

### Backend: Configurar database + modelos
- Criar backend/app/db.py com SQLAlchemy async engine, criar backend/app/models/llm_response_model.py com tabela llm_responses (id, pdf_id, question, answer, subject, embedding vector, created_at), migration script para ativar extensão pgvector

### Backend: Serviço de extração de texto PDF
- Criar backend/app/services/pdf_text_service.py usando pdfplumber, método extract_pages(pdf_path: Path, start_page: int, end_page: int) -> str para extrair intervalo, método extract_all(pdf_path: Path) -> str para PDF completo

### Backend: Serviço LangChain + Gemini + RAG
- Criar backend/app/services/llm_service.py com ChatGoogleGenerativeAI(model="gemini-1.5-flash"), implementar RAG usando PGVector para buscar respostas similares por pdf_id, função preprocess_prompt() para remover espaços/quebras desnecessários, estruturar system message para retornar JSON {ordem_logica: [], exemplos_praticos: [], assunto: ""}, método async stream_response() usando llm.astream()

### Backend: Endpoint SSE para streaming LLM
- Criar backend/app/routes/llm_routes.py com POST /api/llm/chat/stream, receber payload (pdf_filename, page_start, page_end ou null para RAG, question), extrair texto do PDF via PDFTextService, buscar contexto adicional via RAG (3 respostas similares), chamar llm_service.stream_response(), retornar EventSourceResponse com chunks SSE no formato data: {"text": "...", "done": false}\n\n

### Backend: Persistir resposta após streaming
- Adicionar endpoint POST /api/llm/persist em backend/app/routes/llm_routes.py, receber resposta completa (question, answer, subject, pdf_id), parsear JSON do LLM para extrair assunto, gerar embedding usando GoogleGenerativeAIEmbeddings, salvar no PostgreSQL com vector, retornar confirmação com ID

### Flutter: Adicionar dependências Bloc
- Atualizar pubspec.yaml com flutter_bloc: ^8.1.3, equatable: ^2.0.5, executar flutter pub get

### Flutter: Serviço API para chat SSE
- Criar lib/services/i_llm_service.dart (interface), criar lib/services/llm_api_service.dart usando Dio com responseType: ResponseType.stream, método Stream<String> streamChatWithPdf({required String question, required String pdfFilename, int? pageStart, int? pageEnd}), parsear SSE format (data: {json}\n\n), acumular texto e fazer yield incremental, detectar flag done: true para finalizar

### Flutter: Bloc para gerenciar estado do chat
- Criar lib/features/chat/bloc/chat_bloc.dart, chat_event.dart com SendQuestionEvent(question, pageStart, pageEnd) e PersistResponseEvent, chat_state.dart com ChatStreaming(partialResponse), ChatComplete(fullResponse), usar emit.forEach para escutar stream de LlmApiService, ao completar dispara auto-persistência via PersistResponseEvent

### Flutter: Widget sidebar com dropdown + slider
- Criar lib/widgets/llm_sidebar_widget.dart com BlocProvider<ChatBloc>, dropdown para escolher modo ("Página Atual", "Intervalo de Páginas", "Documento Inteiro (RAG)"), slider ou dois TextField para intervalo, TextField para pergunta, ListView.builder para histórico de mensagens (usuário + LLM), exibir resposta estruturada parseando JSON (ordem lógica em cards, exemplos práticos com ícones), botão enviar dispara evento

### Flutter: Integrar sidebar no PdfReaderScreen
- Modificar pdf_reader_screen.dart para layout Row([Expanded(flex: 7, child: PdfViewerWidget()), VerticalDivider(), Expanded(flex: 3, child: LLMSidebarWidget())]), passar _currentPage, _totalPages, _currentPdfUrl (extrair filename), instanciar ChatBloc via BlocProvider com LlmApiService injetado, adicionar ícone toggle para mostrar/ocultar sidebar