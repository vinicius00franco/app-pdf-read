from fastapi import APIRouter
from app.db import SessionLocal, Base, engine
from app.models.llm_response_model import LlmResponse
from sqlalchemy import Float

router = APIRouter()

Base.metadata.create_all(bind=engine)

def simple_embed(text: str, size: int = 128):
    import hashlib
    h = hashlib.sha256(text.encode()).digest()
    vec = [b / 255.0 for b in h[:size if size <= len(h) else len(h)]]
    if len(vec) < size:
        vec += [0.0] * (size - len(vec))
    return vec

@router.post('/persist')
def persist(payload: dict):
    pdf_id = payload.get('pdf_id')
    question = payload.get('question', '')
    answer = payload.get('answer', '')
    subject = payload.get('subject', '')
    emb = simple_embed(answer)
    db = SessionLocal()
    try:
        item = LlmResponse(pdf_id=pdf_id, question=question, answer=answer, subject=subject, embedding=emb)
        db.add(item)
        db.commit()
        return {'status': 'ok'}
    finally:
        db.close()