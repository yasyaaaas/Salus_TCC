# security.py -> hash e verifica senha, cria e decodifica token de acesso

from passlib.context import CryptContext
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Criptografa a senha do usuário usando o algoritmo bcrypt
def hash_password(password: str) -> str:
    return pwd_context.hash(password)

# Verifica se a senha fornecida pelo usuário corresponde à senha criptografada armazenada no banco de dados
def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

SECRET_KEY = "sanasasukeamoreterno123"  # chave secreta usada para criar e ler o token
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440  # 24 horas

def create_access_token(email: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES) # tempo de expiração do token
    payload = {"sub": email, "exp": expire} # payload do token -> sub é o id do usuário que está logando, exp é o tempo de expiração do token
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM) # cria o chave encriptografada do token


def decode_access_token(token: str) -> str | None:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM]) # decodifica o token com a chave secreta e o algoritmo de criptografia
        return payload.get("sub") # devolve o id do usuário que está logando
    except JWTError:
        return None