from typing import List, Optional
from pathlib import Path

from app.pdf_model import PDFModel, PDFUploadResponse
from app.pdf_repository import PDFRepository

class PDFService:
    def __init__(self, repository: PDFRepository):
        self.repository = repository

    def upload_pdf(self, filename: str, file_content: bytes) -> PDFUploadResponse:
        """Processa o upload de um PDF"""
        if not filename.lower().endswith('.pdf'):
            raise ValueError("Only PDF files are allowed")

        pdf_model = self.repository.save_pdf(filename, file_content)

        return PDFUploadResponse(
            id=pdf_model.id,
            filename=pdf_model.filename,
            url=pdf_model.url,
            uploaded_at=pdf_model.uploaded_at,
            file_size=pdf_model.file_size
        )

    def get_pdf_file(self, filename: str) -> Optional[Path]:
        """Retorna o arquivo PDF para download"""
        return self.repository.get_pdf_by_filename(filename)

    def delete_pdf(self, filename: str) -> bool:
        """Remove um PDF"""
        return self.repository.delete_pdf(filename)

    def list_pdfs(self) -> List[PDFModel]:
        """Lista todos os PDFs"""
        return self.repository.list_pdfs()

    def get_pdf_info(self, filename: str) -> Optional[PDFModel]:
        """Retorna informações de um PDF"""
        return self.repository.get_pdf_info(filename)