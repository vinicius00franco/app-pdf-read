from fastapi import APIRouter

# Router para rotas de sistema/health
system_router = APIRouter()

@system_router.get("/health")
async def health_check():
    """Endpoint de verificação de saúde da API"""
    return {"status": "healthy", "service": "PDF Storage API"}

@system_router.get("/")
async def root():
    """Endpoint raiz da API"""
    return {
        "message": "PDF Storage API",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc",
        "health": "/api/system/health"
    }