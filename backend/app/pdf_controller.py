from fastapi import APIRouter, File, UploadFile, HTTPException, Depends
from fastapi.responses import FileResponse
from typing import List

from .pdf_model import PDFUploadResponse, PDFListResponse
from ..pdf_service import PDFService
from .pdf_repository import PDFRepository

router = APIRouter()

def get_pdf_service() -> PDFService:
    """Dependency injection para o serviço de PDF"""
    repository = PDFRepository()
    return PDFService(repository)

@router.post("/upload-pdf", response_model=PDFUploadResponse)
async def upload_pdf(
    file: UploadFile = File(...),
    pdf_service: PDFService = Depends(get_pdf_service)
):
    """Upload de um arquivo PDF"""
    try:
        # Lê o conteúdo do arquivo
        file_content = await file.read()

        # Processa o upload através do serviço
        result = pdf_service.upload_pdf(file.filename, file_content)

        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error uploading PDF: {str(e)}")

@router.get("/pdfs/{filename}")
async def get_pdf(
    filename: str,
    pdf_service: PDFService = Depends(get_pdf_service)
):
    """Download de um PDF"""
    file_path = pdf_service.get_pdf_file(filename)

    if file_path is None:
        raise HTTPException(status_code=404, detail="PDF not found")

    return FileResponse(
        path=file_path,
        media_type='application/pdf',
        filename=filename
    )

@router.delete("/pdfs/{filename}")
async def delete_pdf(
    filename: str,
    pdf_service: PDFService = Depends(get_pdf_service)
):
    """Exclusão de um PDF"""
    success = pdf_service.delete_pdf(filename)

    if not success:
        raise HTTPException(status_code=404, detail="PDF not found")

    return {"message": "PDF deleted successfully"}

@router.get("/pdfs", response_model=PDFListResponse)
async def list_pdfs(
    pdf_service: PDFService = Depends(get_pdf_service)
):
    """Lista todos os PDFs"""
    pdfs = pdf_service.list_pdfs()
    return PDFListResponse(pdfs=pdfs, total=len(pdfs))