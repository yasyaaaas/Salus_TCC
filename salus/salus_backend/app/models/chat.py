# chat.py -> tabela das perguntas no banco (para o histórico)

import uuid
from datetime import datetime, UTC

from sqlalchemy import DateTime, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.database import Base


class ChatMessage(Base): # tabela de mensagens mandadas ao chat
    __tablename__ = "chat_messages"

    id: Mapped[int] = mapped_column(primary_key=True)

    # garante quei toda mensagem pertença ao usúario que mandou ela
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), nullable=False) #  ligação entre a mensagem e o usuário dono dela

    mensagem_usuario: Mapped[str] = mapped_column(Text, nullable=False)
    resposta_chatbot: Mapped[str] = mapped_column(Text, nullable=False)

    manchester_color: Mapped[str] = mapped_column(String(20), nullable=True)
    manchester_label: Mapped[str] = mapped_column(String(80), nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now(UTC)) # date/time ->  toda mensagem nova já nasce com a data/hora atual