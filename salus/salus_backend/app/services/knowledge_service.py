# knowledge_service.py -> analiza o texto do usuario e identifa os sintomas qeu aparecem nele (o qeu o gemini vai usar)

from sqlalchemy.orm import Session
from app.models.knowledge import Symptom, Condition

ORDEM_URGENCIA = {"vermelho": 0, "laranja": 1, "amarelo": 2, "verde": 3, "azul": 4}

# palavras qeu se podem pular
STOPWORDS = {
    "de", "da", "do", "das", "dos", "e", "a", "o", "os", "as", "em", "com",
    "há", "para", "por", "no", "na", "nos", "nas", "um", "uma", "uns", "umas",
    "ou", "que", "se", "sem", "ao", "aos", "à", "às", "meu", "minha",
}

# palavras que qualificam intensidade não a identidade do sintoma
INTENSIDADE = {
    "alta", "leve", "forte", "fortes", "intensa", "intenso", "moderada",
    "moderado", "severa", "severo", "aguda", "agudo", "crônica", "crônico",
}

# remove stopwords e palavras de intensidade sobrando as palavras qeu identificam o sintoma
def palavras_essenciais(nome_sintoma: str) -> list[str]:
    palavras = [
        p for p in nome_sintoma.split()
        if p not in STOPWORDS and p not in INTENSIDADE
    ]
    return palavras or nome_sintoma.split()  # nunca devolve lista vazia

# Só bate se TODAS as palavras essenciais do sintoma estiverem no texto
def sintoma_bate_no_texto(nome_sintoma: str, palavras_do_texto: set[str]) -> bool:
    essenciais = palavras_essenciais(nome_sintoma)
    return all(palavra in palavras_do_texto for palavra in essenciais)


# retorna una lista de dincionário cada um com do dados da sua condição
def buscar_condicoes_relacionadas(texto_usuario: str, db: Session, top_n: int = 3) -> list[dict]:  # top_n -> top 3 condições mais provaveis
    texto_normalizado = texto_usuario.lower()
    palavras_do_texto = set(texto_normalizado.split())  # quebra a frase em palavras únicas

    todos_sintomas = db.query(Symptom).all()
    sintomas_encontrados = [
        s for s in todos_sintomas if sintoma_bate_no_texto(s.name, palavras_do_texto)
    ] # STRING MATCHING -> a cada sintoma olha se o nome dele está na query do usuário, se sim adiciona a lista de sintomas

    if not sintomas_encontrados:
        return [] # se nehum foi encontrado retornamos uma lista vazia

    # soma os pesos por condição, considerando só os sintomas que bateram no texto
    pontuacao_por_condicao: dict[int, float] = {}  # para cada condição (pelo id dela) a soma dos pesos dos sintomas mencionados que estão associados a ela (id, peso)
    condicao_por_id: dict[int, Condition] = {} # vai guardar o objeto inteiro da condição (com nome, c_id, etc.) chave é o id (id , <Condition(x)>)

    for sintoma in sintomas_encontrados: # a cada sintoma encontrado
        identidade = tuple(sorted(palavras_essenciais(sintoma.name))) # transforma febre alta e febre leve em febre 
        # quando acessamos sintoma.conditions, faz uma consulta no banco e devolve todos os registros da symptom_condition onde symptom_id = 1 e vê a condição associada a ele
        for vinculo in sintoma.conditions:  # SymptomCondition -> a partir do obj Symptom eu consigo ver os obj da tabela SymptomCondition qeu referenciam esse sintoma
            condicao = vinculo.condition # cada vinculo pega o objeto Condition
            condicao_por_id[condicao.id] = condicao
            pesos_da_condicao = pontuacao_por_condicao.setdefault(condicao.id, {})
            # só guarda se for maior que o que já tinha pra essa mesma identidade
            pesos_da_condicao[identidade] = max(
                pesos_da_condicao.get(identidade, 0), vinculo.weight
            )

    # a pontuação final de cada condição é a SOMA dos maiores pesos por identidade
    pontuacao_final: dict[int, float] = {
        c_id: sum(pesos.values()) for c_id, pesos in pontuacao_por_condicao.items()
    }

    # ordena por pontuação (maior primeiro) em empate prioriza a cor mais urgente
    ids_ordenados = sorted(
        pontuacao_final,
        key=lambda c_id: (
            -pontuacao_final[c_id],
            ORDEM_URGENCIA[condicao_por_id[c_id].manchester_color],
        ),
    )

    resultado = []
    for c_id in ids_ordenados[:top_n]:  # pega os primeiros top_n da lista
        condicao = condicao_por_id[c_id] # para cada id pega a condição do condicao_por_id e monta o dicionario com todos os campos do db
        resultado.append({
            "name": condicao.name,
            "cid10": condicao.cid10,
            "manchester_color": condicao.manchester_color,
            "manchester_label": condicao.manchester_label,
            "informative_message": condicao.informative_message,
            "pontuacao": round(pontuacao_final[c_id], 2),
        })

    return resultado