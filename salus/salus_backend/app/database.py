# database.py -> cria a conexão com o banco de dados e cria a sessão para falar com o banco

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

DATABASE_URL = "postgresql://salus:cruzeiro_459@localhost:5432/salus_db" # vem do docker

engine = create_engine(DATABASE_URL) # sabe como falar com esse banco
SessionLocal = sessionmaker(bind=engine) # cria uma sessão para falar com o banco

class Base(DeclarativeBase): # molde para as tabelas
    pass

# cada requisição que chega precisa da sua própria conversa com o banco

def get_db():
    db = SessionLocal()
    try:
        yield db # vai dar o db para a função que chamou o get_db e depois que a função que chamou o get_db terminar, ele vai fechar a conexão com o banco
    finally:
        db.close()