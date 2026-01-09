# Rotas da API PDF Storage

## Base URL
- Local: `http://localhost:8000`
- Rede: `http://0.0.0.0:8000`

## Rotas Disponíveis

### Sistema
- **GET** `/api/system/` - Informações da API
- **GET** `/api/system/health` - Verificação de saúde

### PDFs
- **POST** `/api/pdfs/upload` - Upload de PDF (multipart/form-data)
- **GET** `/api/pdfs/{filename}` - Download de PDF
- **DELETE** `/api/pdfs/{filename}` - Exclusão de PDF
- **GET** `/api/pdfs/` - Listar todos os PDFs

### Arquivos Estáticos
- **GET** `/pdfs/{filename}` - Acesso direto aos arquivos PDF