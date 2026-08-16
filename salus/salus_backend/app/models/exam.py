# exam.py -> guarda o resultado de cada análise de exame feita pelo usuário

import uuid
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.database import Base

class ExamAnalysis(Base):
    __tablename__ = "exam_analyses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    nome_arquivo = Column(String, nullable=True)
    resultados = Column(JSON, nullable=False)  # lista de dicts (parametro, valor, status, mensagem...)
    created_at = Column(DateTime(timezone=True), server_default=func.now())