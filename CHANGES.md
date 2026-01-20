## 2026-01-10
- Adicionados serviços: `pdf_extractor_service`, `gemini_service`, `llm_persistence_service`.
- Implementado `ChatBloc` com verificação de 30k tokens e streaming.
- Criado `LLMSidebarWidget` e integrado ao `PdfReaderScreen`.
- Atualizado `pubspec.yaml` com dependências Gemini, Bloc, Equatable e Syncfusion.
- Backend: adicionados `docker-compose.yml`, `db.py`, modelo `LlmResponse`, rota `/api/llm/persist` e inclusão no `main.py`.