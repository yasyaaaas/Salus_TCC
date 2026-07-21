# app/auth_deps.py -> get_current_user -> extrai o usuário atual da requisição, se não tiver token, retorna erro de credencial

from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.user import User
from app.core.security import decode_access_token

security = HTTPBearer() # cria um esquema de segurança do tipo Bearer, que é o tipo de token que vamos usar para autenticação

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security), # extrai o token da requisição, se não tiver token, retorna erro de credencial
    db: Session = Depends(get_db), # extrai a sessão do banco de dados
) -> User:
    erro_de_credencial = HTTPException( # erro de credencial -> se o token for inválido, retorna erro de credencial
        status_code=401,
        detail="Não foi possível validar as credenciais",
    )

    token = credentials.credentials # pega o token da requisição
    email = decode_access_token(token) # pega o email do token decodificado, se o token for inválido, retorna None
    if email is None:
        raise erro_de_credencial

    usuario = db.query(User).filter(User.email == email).first() # busca o usuário no banco pelo e-mail decodificado do token
    if usuario is None:
        raise erro_de_credencial # se o usuário não for encontrado, retorna erro de credencial

    return usuario