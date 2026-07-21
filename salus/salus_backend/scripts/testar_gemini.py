from app.db.database import SessionLocal
from app.services.chat_services import processar_mensagem_chat

db = SessionLocal()
resultado = processar_mensagem_chat("estou com dor de cabeça forte e febre há 2 dias", db)

print("Cor:", resultado["manchester_color"], "-", resultado["manchester_label"])
for c in resultado["condicoes_relacionadas"]:
    print(c["name"], "-", c["pontuacao"], "-", c["manchester_color"])

db.close()