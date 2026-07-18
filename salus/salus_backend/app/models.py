# app/models.py -> tabela de usuários no banco de dados

import uuid
from sqlalchemy import String, Integer, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base # Herda da Base para criar a tabela no banco


class User(Base):
    __tablename__ = "users" # TABELA DOS USUARIOS NO BANCO DE DADOS

    id: Mapped[uuid.UUID] = mapped_column(  # código único gigante -> SEGURANÇA
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    full_name: Mapped[str] = mapped_column(String(150), nullable=False) # nome
    email: Mapped[str] = mapped_column(String(150), unique=True, nullable=False) # email
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False) # senha criptografada

    age: Mapped[int] = mapped_column(Integer, nullable=False) # idade
    weight_kg: Mapped[float] = mapped_column(Float, nullable=False) # peso em kg
    height_cm: Mapped[int] = mapped_column(Integer, nullable=False) # altura em cm
    gender: Mapped[str] = mapped_column(String(20), nullable=False) # sexo do usuário (masculino, feminino, outro)

    avatar: Mapped[str] = mapped_column(String(50), nullable=False, default="Navely.png") # avatar do usuário (imagem padrão)

    @property # cria atributo calculado -> não é armazenado no banco, mas é calculado a partir de outros atributos
    def imc(self) -> float: # calcula o IMC do usuário
        if not self.height_cm:
            return 0.0
        altura_m = self.height_cm / 100
        return round(self.weight_kg / (altura_m ** 2), 1)

    @property
    def imc_classification(self) -> str: # classifica o IMC do usuário
        valor = self.imc
        if valor < 18.5:
            return "Abaixo do peso"
        if valor < 25.0:
            return "Peso normal"
        if valor < 30.0:
            return "Sobrepeso"
        if valor < 35.0:
            return "Obesidade grau I"
        if valor < 40.0:
            return "Obesidade grau II"
        return "Obesidade grau III"