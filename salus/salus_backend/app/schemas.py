# schemas.py -> moldes de validação de dados -> o que entra e o que sai da API

import uuid
from pydantic import BaseModel, EmailStr, Field, field_validator

class UserCreate(BaseModel): # descreve o que entra na requisição (o cliente manda nome, e-mail, senha)
    full_name: str
    email: EmailStr
    password: str
    age: int
    weight_kg: float
    height_cm: int
    gender: str


class UserOut(BaseModel): # descreve o que que sai na resposta (nunca devolvemos a senha/hash para o cliente)
    id: uuid.UUID
    full_name: str
    email: EmailStr
    age: int
    weight_kg: float
    height_cm: int
    gender: str
    avatar: str
    imc: float # consegue ler por conta do @property no model
    imc_classification: str

    class Config:
        from_attributes = True # Diz ao Pydantic para ler os dados de atributos de um objeto


class LoginRequest(BaseModel):
    email: EmailStr # email do usuário que está tentando logar
    password: str # senha do usuário que está tentando logar


class TokenResponse(BaseModel):
    access_token: str # token de acesso do usuário
    token_type: str = "bearer" # esse token é do tipo carregador/portador

AVATARES_VALIDOS = {
    "Chaengvely.png", "Davely.png", "Jeongvely.png", "Jively.png",
    "Mively.png", "Movely.png", "Navely.png", "Savely.png", "Tzuvely.png",
}

class UserUpdate(BaseModel): # descreve o que entra na requisição de atualização do usuário
    full_name: str | None = None
    age: int | None = Field(default=None, gt=0, le=120)
    weight_kg: float | None = Field(default=None, gt=0, le=300)
    height_cm: int | None = Field(default=None, gt=0, le=250)
    gender: str | None = None
    avatar: str | None = None

    @field_validator("avatar") # valida o avatar do usuário
    @classmethod
    def validar_avatar(cls, valor):
        if valor is not None and valor not in AVATARES_VALIDOS:
            raise ValueError(f"Avatar inválido. Opções: {', '.join(AVATARES_VALIDOS)}")
        return valor