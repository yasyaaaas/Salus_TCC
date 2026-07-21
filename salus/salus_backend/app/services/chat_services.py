# chat_services.py ->

from sqlalchemy.orm import Session

from app.services.gemini_service import gerar_resposta_chatbot
from app.services.knowledge_service import buscar_condicoes_relacionadas


def processar_mensagem_chat(mensagem_usuario: str, db: Session) -> dict:
    condicoes_relacionadas = buscar_condicoes_relacionadas(mensagem_usuario, db) # pela mensagem do usuario já busca as condições relacionadas

    # monta um contexto extra pro Gemini, citando o que a base já sugeriu
    contexto_base = ""
    if condicoes_relacionadas:
        nomes = ", ".join(c["name"] for c in condicoes_relacionadas) # lista de condições separadas por virgula
        contexto_base = (
            f"\n\n(Contexto interno: a base de conhecimento do Salus sugere "
            f"possível relação com: {nomes}. Use isso como apoio, mas responda "
            f"de forma natural, sem citar que consultou uma base de dados.)"
        )

    # para a resposat do chat se manda a mensagem do usuario mais a lista de condições já apuradas
    resposta_gemini = gerar_resposta_chatbot(mensagem_usuario + contexto_base) 

    if resposta_gemini is None: # se não tiver resposta coloca um apadrão
        resposta_gemini = (
            "Não foi possível gerar uma orientação no momento. "
            "Recomendamos procurar atendimento médico se os sintomas persistirem."
        )

    # a cor Manchester SEMPRE vem da base estruturada, nunca do texto livre do Gemini
    # decisão de urgência (cor Manchester) fica inteiramente SOB CONTROLE DA MINHA BASE DE DADOS
    if condicoes_relacionadas:
        condicao_principal = condicoes_relacionadas[0]  # primeira condição (a mais povável) já vem ordenada por pontuação do knowlege_services.py
        manchester_color = condicao_principal["manchester_color"]
        manchester_label = condicao_principal["manchester_label"]
    else:
        manchester_color = None
        manchester_label = None

    return { # retorna a resposaat do usuario a cor mancherter a label e as condições relacionadas
        "resposta": resposta_gemini,
        "manchester_color": manchester_color,
        "manchester_label": manchester_label,
        "condicoes_relacionadas": condicoes_relacionadas,
    }