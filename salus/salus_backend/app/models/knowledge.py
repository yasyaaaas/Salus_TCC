# knowledge.py -> tabela de doenças no banco de dados

from sqlalchemy import Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base # importa base para as tabelas


class Symptom(Base):
    __tablename__ = "symptoms" # tabela de sintomas

    id: Mapped[int] = mapped_column(Integer, primary_key=True) 
    name: Mapped[str] = mapped_column(String(120), unique=True, nullable=False)

    # Um sintoma pode estar associado a várias instâncias da tabela SymptomCondition
    conditions: Mapped[list["SymptomCondition"]] = relationship(back_populates="symptom") 


class Condition(Base):
    __tablename__ = "conditions" # tabela de doenças

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    cid10: Mapped[str] = mapped_column(String(10), nullable=True)
    informative_message: Mapped[str] = mapped_column(Text, nullable=False)
    manchester_color: Mapped[str] = mapped_column(String(20), nullable=False)
    manchester_label: Mapped[str] = mapped_column(String(80), nullable=False)

    # uma doença pode estar associada a várias instâncias da tabela SymptomCondition
    symptoms: Mapped[list["SymptomCondition"]] = relationship(back_populates="condition")


class SymptomCondition(Base): # tabela de ligação
    __tablename__ = "symptom_condition" # acionamento entre duas outras tabelas (sintoma <-> doença)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    symptom_id: Mapped[int] = mapped_column(ForeignKey("symptoms.id"))
    condition_id: Mapped[int] = mapped_column(ForeignKey("conditions.id"))
    weight: Mapped[float] = mapped_column(Float, default=0.5) # o peso desse sintoma nessa doença

    # relacionamentos de ida para as tabelas principais
    symptom: Mapped["Symptom"] = relationship(back_populates="conditions")
    condition: Mapped["Condition"] = relationship(back_populates="symptoms")

# no .cscv fica tipo a cada linha
# cria uma nova Condition com name="Dengue", cid10="A90", manchester_color="laranja"...
# para cada par no campo symptoms (ex: "febre alta:1.0") procura ou cria uma Symptom com name="febre alta"
# cria uma nova SymptomCondition, ligando o symptom_id ao id do sintoma, o condition_id ao id da Dengue, e weight=1.0