from sqlalchemy import Column, Integer, String, Text, Float
from sqlalchemy.dialects.postgresql import ARRAY
from app.db import Base

class LlmResponse(Base):
    __tablename__ = 'llm_responses'

    id = Column(Integer, primary_key=True, index=True)
    pdf_id = Column(String, index=True)
    question = Column(Text)
    answer = Column(Text)
    subject = Column(String)
    embedding = Column(ARRAY(Float))