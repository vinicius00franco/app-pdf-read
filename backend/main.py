from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from app.routes.pdf_routes import pdf_router
from app.routes.system_routes import system_router

# Cria a aplicação FastAPI
app = FastAPI(
    title="PDF Storage API",
    description="API para armazenamento e gerenciamento de arquivos PDF",
    version="1.0.0"
)

# Configuração CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especifique os domínios permitidos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Monta arquivos estáticos para servir PDFs
app.mount("/pdfs", StaticFiles(directory="assets"), name="pdfs")

# Inclui as rotas da API organizadas por feature
app.include_router(system_router, prefix="/api/system", tags=["system"])
app.include_router(pdf_router, prefix="/api/pdfs", tags=["pdfs"])