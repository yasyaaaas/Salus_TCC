# knowledge_service.py -> analiza o texto do usuario e identifa os sintomas qeu aparecem nele (o qeu o gemini vai usar)

import re

from sqlalchemy.orm import Session
from unidecode import unidecode
from app.models.knowledge import Symptom, Condition

ORDEM_URGENCIA = {"Vermelho": 0, "Laranja": 1, "Amarelo": 2, "Verde": 3, "Azul": 4}

# normaliza texto (minúsculas, sem acento, sem pontuação)
def normalizar(t: str) -> str:
    if not t:
        return ""
    t = t.lower()
    t = unidecode(t) # "cabeça" -> "cabeca"
    t = re.sub(r"[^\w\s]", " ", t) # vírgula/ponto -> espaço
    t = re.sub(r"\s+", " ", t).strip()
    return t


# normaliza o valor da cor para bater com o dicionário em minúsculo
def ordem_cor(cor: str | None) -> int:
    if not cor:
        return 99
    return ORDEM_URGENCIA.get(cor.strip().lower(), 99)


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


# normaliza os conjuntos UMA vez, para comparar sem acento
STOPWORDS = {normalizar(p) for p in STOPWORDS}
INTENSIDADE = {normalizar(p) for p in INTENSIDADE}

# remove stopwords e palavras de intensidade sobrando as palavras qeu identificam o sintoma
def palavras_essenciais(nome_sintoma: str) -> list[str]:
    nome_norm = normalizar(nome_sintoma)
    palavras = [
        p for p in nome_norm.split()
        if p not in STOPWORDS and p not in INTENSIDADE
    ]
    return palavras or nome_norm.split()  # nunca devolve lista vazia

# Só bate se TODAS as palavras essenciais do sintoma estiverem no texto
def sintoma_bate_no_texto(nome_sintoma: str, palavras_do_texto: set[str]) -> bool:
    essenciais = palavras_essenciais(nome_sintoma)
    return all(palavra in palavras_do_texto for palavra in essenciais)


# retorna una lista de dincionário cada um com do dados da sua condição
def buscar_condicoes_relacionadas(texto_usuario: str, db: Session, top_n: int = 3) -> list[dict]:  # top_n -> top 3 condições mais provaveis
    palavras_do_texto = set(normalizar(texto_usuario).split())

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
            ordem_cor(condicao_por_id[c_id].manchester_color),
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
            "pontuacao": round(pontuacao_final[c_id], 2),
        })

    return resultado