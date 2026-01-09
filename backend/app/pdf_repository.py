import os
import uuid
from pathlib import Path
from typing import List, Optional
from datetime import datetime

from .pdf_model import PDFModel

class PDFRepository:
    def __init__(self, upload_dir: str = "assets"):
        self.upload_dir = Path(upload_dir)
        self.upload_dir.mkdir(exist_ok=True)

    def save_pdf(self, filename: str, file_content: bytes) -> PDFModel:
        """Salva um PDF no sistema de arquivos e retorna o modelo"""
        file_id = str(uuid.uuid4())
        file_extension = Path(filename).suffix
        unique_filename = f"{file_id}{file_extension}"

        file_path = self.upload_dir / unique_filename
        file_path.write_bytes(file_content)

        pdf_model = PDFModel(
            id=file_id,
            filename=filename,
            url=f"/pdfs/{unique_filename}",
            file_path=str(file_path),
            uploaded_at=datetime.now(),
            file_size=len(file_content)
        )

        return pdf_model

    def get_pdf_by_filename(self, filename: str) -> Optional[Path]:
        """Retorna o caminho do arquivo PDF se existir"""
        file_path = self.upload_dir / filename
        if file_path.exists():
            return file_path
        return None

    def delete_pdf(self, filename: str) -> bool:
        """Remove um PDF do sistema de arquivos"""
        file_path = self.upload_dir / filename
        if file_path.exists():
            file_path.unlink()
            return True
        return False

    def list_pdfs(self) -> List[PDFModel]:
        """Lista todos os PDFs salvos"""
        pdfs = []
        for file_path in self.upload_dir.glob("*"):
            if file_path.is_file():
                # Para simplificar, vamos criar um modelo básico
                # Em um sistema real, você poderia armazenar metadados em um banco
                pdf_model = PDFModel(
                    id=file_path.stem,  # usa o nome do arquivo como ID aproximado
                    filename=file_path.name,
                    url=f"/pdfs/{file_path.name}",
                    file_path=str(file_path),
                    uploaded_at=datetime.fromtimestamp(file_path.stat().st_mtime),
                    file_size=file_path.stat().st_size
                )
                pdfs.append(pdf_model)
        return pdfs

    def get_pdf_info(self, filename: str) -> Optional[PDFModel]:
        """Retorna informações de um PDF específico"""
        file_path = self.upload_dir / filename
        if file_path.exists():
            return PDFModel(
                id=file_path.stem,
                filename=file_path.name,
                url=f"/pdfs/{file_path.name}",
                file_path=str(file_path),
                uploaded_at=datetime.fromtimestamp(file_path.stat().st_mtime),
                file_size=file_path.stat().st_size
            )
        return None