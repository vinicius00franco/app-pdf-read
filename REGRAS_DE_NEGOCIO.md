## Chat LLM
- Respostas devem retornar JSON válido com campos: `ordem_logica`, `exemplos_praticos`, `assunto`.
- Se o contexto estimado exceder 30k tokens, exibir mensagem de erro fixa na sidebar e bloquear envio.
- Extração de texto: usar Syncfusion; fallback para imagem quando não houver camada de texto.
- Persistir respostas completas no backend via `/api/llm/persist`.