# Flutter PDF Reader - Contexto Arquitetural

## Tipo de Projeto
- Aplicativo Flutter multiplataforma
- Leitor de PDF com cache e persistência

## Estrutura Principal

### Camadas
- **Presentation**: `screens/`, `widgets/`
- **Services**: `services/` (interfaces + implementações)
- **Main**: Configuração e DI


## Dependências Principais
- `pdfx` - Renderização PDF
- `file_picker` - Seleção arquivos
- `path_provider` - Diretórios sistema
- `shared_preferences` - Persistência local

## Funcionalidades Técnicas

### Performance
- Compressão gzip automática
- Cache de arquivos processados
- Lazy loading

### Persistência
- Última página lida salva
- Cache em disco

### Estado
- Página atual/total gerenciada no widget
- Salvamento automático via SharedPreferences

## Padrões Utilizados
- Clean Architecture (camadas separadas)
- Dependency Injection manual
- Interface segregation
- Stateful/Stateless widgets

## Multiplataforma
- Android, iOS, Windows, macOS, Linux, Web
- Configurações específicas por plataforma

## Controle de Mudanças
- Toda mudança feita deve ser registrada em CHANGES.md
- Toda regra de negócio existente, alterada ou excluída deve ser adicionada em REGRAS_DE_NEGOCIO.md
- Toda mudança no código deve analisar o contexto do código e suas regras