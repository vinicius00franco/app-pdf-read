from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class PDFModel(BaseModel):
    id: str
    filename: str
    url: str
    file_path: str
    uploaded_at: datetime
    file_size: int

class PDFUploadResponse(BaseModel):
    id: str
    filename: str
    url: str
    uploaded_at: datetime
    file_size: int

class PDFListResponse(BaseModel):
    pdfs: list[PDFModel]
    total: int