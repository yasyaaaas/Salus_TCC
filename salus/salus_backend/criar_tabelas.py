# criar_tabelas.py -> cria as tabelas no banco de dados (avulso por agora)

from app.database import Base, engine
from app.models import User  # precisa importar, mesmo sem usar diretamente

Base.metadata.create_all(bind=engine)
print("Tabelas criadas com sucesso!")