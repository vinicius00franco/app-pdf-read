# Flutter PDF Reader with API Backend

Este projeto foi atualizado para usar uma arquitetura com backend API em FastAPI para armazenamento e servir de PDFs, resolvendo problemas de persistência local.

## Arquitetura

- **Frontend**: Flutter app com Dio para requisições HTTP
- **Backend**: FastAPI para upload, armazenamento e servir de PDFs
- **Armazenamento**: PDFs salvos no servidor em vez de localmente

## Como executar

### 1. Backend (FastAPI)

**Opção 1 - Windows:**
```bash
run_backend.bat
```

**Opção 2 - Manual:**
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

A API estará disponível em `http://localhost:8000`

### 2. Frontend (Flutter)

```bash
flutter pub get
flutter run
```

## Configuração da API

No arquivo `lib/services/pdf_api_service.dart`, configure a URL base:

```dart
// Para Android Emulator
static const String _baseUrl = 'http://10.0.2.2:8000';

// Para iOS Simulator ou Web
// static const String _baseUrl = 'http://localhost:8000';
```

## Funcionalidades

- Upload de PDFs para o servidor
- Visualização de PDFs via URL
- Lista de PDFs salvos
- Exclusão de PDFs do servidor
- Salvamento da página atual por PDF

## API Endpoints

- `POST /upload-pdf` - Upload de PDF
- `GET /pdfs/{filename}` - Download de PDF
- `DELETE /pdfs/{filename}` - Exclusão de PDF

## Mudanças da versão anterior

- Removida compressão gzip local
- PDFs agora são servidos via HTTP
- Uso de Dio para requisições HTTP
- Armazenamento centralizado no servidor
- Resolvido problema de "Can't open file" ao abrir PDFs salvos