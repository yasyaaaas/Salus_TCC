# exam_service.py -> extrai texto do laudo em PDF, separa por exame e interpreta o resultado
# usando o próprio valor de referência impresso no laudo assim não depende de banco

import re
import fitz


# extrai o texto completo do PDF para depois separar os exames e interpretar os resultados
def extrair_texto_pdf(conteudo_bytes: bytes) -> str:
    doc = fitz.open(stream=conteudo_bytes, filetype="pdf") # abre o arquivo PDF a partir dos bytes recebidos
    linhas_completas = []
    for page in doc: # percorre cada página do PDF
        d = page.get_text("dict") # pega o texto da página em formato estruturado, basicamente página ->  blocos (blocks) ->  linhas (lines)->  span (spans)
        linhas_pagina = {}
        for block in d["blocks"]: # percorre cada bloco de texto da página (geralmente um parágrafo ou tabela)
            for line in block.get("lines", []): # percorre cada linha do bloco (geralmente uma linha de texto ou uma linha de tabela)
                y_key = round(line["bbox"][1], 0)  # agrupa spans da mesma linha visual -> y_key é a posição vertical da linha arredondada para evitar pequenas diferenças de posição
                partes = []
                for span in line["spans"]: # percorre cada trecho de texto dentro da linha (geralmente uma palavra ou grupo de palavras com a mesma formatação)
                    if "Type3" in span["font"] or span["size"] < 1:
                        continue  # pula as partes usados pra desenhar a grade da tabela
                    partes.append(span["text"]) # adiciona o texto do span à linha
                texto_linha = "".join(partes).strip() # junta as partes e remove espaços extras
                if texto_linha:
                    linhas_pagina.setdefault(y_key, []).append(texto_linha) # guarda a linha na página usando a posição vertical como chave
        for y in sorted(linhas_pagina): # ordena as linhas pela posição vertical
            linhas_completas.append(" ".join(linhas_pagina[y])) # junta as linhas da mesma posição em uma string completa
    return "\n".join(linhas_completas) # devolve o texto final do PDF em formato de texto


# cada exame no laudo começa com um título em CAIXA ALTA seguido de "DATA DA COLETA"
_MARCADOR_BLOCO = re.compile(r'^([A-ZÀ-Ú0-9() \-]{3,80})\n\[DATA DA COLETA', re.MULTILINE) # identifica o início de cada bloco de exame no texto do laudo

# padrão específico pra linha ADULTO (tabela por gênero)
_PADRAO_ADULTO_DUPLO = re.compile(
    r'ADULTO\s+DE\s*([\d.,]+)\s*A\s*([\d.,]+)\s+DE\s*([\d.,]+)\s*A\s*([\d.,]+)',
    re.IGNORECASE
) # identifica a linha de referência do tipo adulto com faixa de valores para homens e mulheres

def dividir_por_exame(texto: str) -> list[dict]:
    matches = list(_MARCADOR_BLOCO.finditer(texto)) # encontra todos os marcadores que iniciam um novo exame
    blocos = []
    for i, m in enumerate(matches): # percorre os blocos encontrados
        titulo = m.group(1).strip() # pega o título do exame
        inicio = m.start() # define o início do bloco
        fim = matches[i + 1].start() if i + 1 < len(matches) else len(texto) # define o fim do bloco até o próximo marcador ou o final do texto
        blocos.append({"titulo": titulo, "texto": texto[inicio:fim]}) # guarda o título e o conteúdo do bloco
    return blocos # devolve a lista de blocos de exame


_PADRAO_RESULTADO = re.compile(
    r'RESULTADO:\s*(?:([A-ZÀ-Ú0-9()\s]{3,60}):\s*)?([\d.,]+)\s*([%A-Za-zµ/]+)'
) # identifica linhas de resultado e o valor numérico associado
_PADRAO_FAIXA = re.compile(
    r'REFER[ÊE]NCIA[S]?:?\s*DE\s*([\d.,]+)\s*A\s*([\d.,]+)', re.IGNORECASE
) # identifica faixas de referência com valor mínimo e máximo
_PADRAO_MENOR = re.compile(r'REFER[ÊE]NCIA[S]?:?\s*MENOR\s*QUE\s*([\d.,]+)', re.IGNORECASE) # identifica referência do tipo menor que
_PADRAO_MAIOR = re.compile(r'REFER[ÊE]NCIA[S]?:?\s*MAIOR\s*QUE\s*([\d.,]+)', re.IGNORECASE) # identifica referência do tipo maior que

_JANELA = 200  # só aceita a referência se ela aparecer logo depois do resultado


def _parse_valor(valor_str: str) -> float:
    return float(valor_str.replace(".", "").replace(",", ".")) # converte o valor textual para número real


def _nome_mais_proximo(texto_bloco: str, pos_resultado: int, titulo_padrao: str) -> str:
    """Procura a linha em CAIXA ALTA mais próxima antes do RESULTADO (ex: 'GLICEMIA MÉDIA
    ESTIMADA' antes de um segundo resultado dentro do mesmo bloco de A1C)."""
    texto_antes = texto_bloco[:pos_resultado] # pega o texto antes do resultado encontrado
    linhas = [l.strip() for l in texto_antes.strip().split("\n") if l.strip()] # separa em linhas e remove espaços vazios
    for linha in reversed(linhas): # percorre as linhas de baixo para cima
        if linha.isupper() and len(linha) > 2 and "RESULTADO" not in linha and "REFER" not in linha:
            return linha # retorna a linha mais próxima em caixa alta antes do resultado
    return titulo_padrao # se não encontrar, usa o título do bloco como nome do parâmetro


def extrair_resultados_do_bloco(bloco: dict, genero_usuario: str) -> list[dict]:
    texto = bloco["texto"] # pega o conteúdo do bloco de exame
    resultados = []
    matches = list(_PADRAO_RESULTADO.finditer(texto)) # pega todos de uma vez pra saber se há mais de 1

    for m in matches: # percorre cada resultado encontrado no texto do bloco
        sublabel, valor_str, unidade = m.groups() # pega o nome do parâmetro, o valor e a unidade
        if sublabel:
            nome = sublabel.strip()
        elif len(matches) > 1:
            nome = _nome_mais_proximo(texto, m.start(), bloco["titulo"]) # usa o sublabel ou tenta descobrir o nome do parâmetro
        else:
            nome = bloco["titulo"]  # bloco com um único resultado -> usa sempre o título do exame
 
        valor = _parse_valor(valor_str) # converte o valor para float
        resto = texto[m.end():] # pega o texto depois do resultado para procurar a referência

        minimo = maximo = None
        interpretavel = True

        adulto = _PADRAO_ADULTO_DUPLO.search(resto) # tenta encontrar a referência de faixa para adultos
        faixa = _PADRAO_FAIXA.search(resto) # tenta encontrar uma faixa de referência comum
        menor = _PADRAO_MENOR.search(resto) # tenta encontrar uma referência do tipo menor que
        maior = _PADRAO_MAIOR.search(resto) # tenta encontrar uma referência do tipo maior que

        if adulto and adulto.start() < _JANELA * 3:  # tabela pode ficar mais longe do RESULTADO
            fem_min, fem_max, masc_min, masc_max = map(_parse_valor, adulto.groups())
            if genero_usuario.lower().startswith("f"):
                minimo, maximo = fem_min, fem_max # usa a faixa de referência para mulheres
            else:
                minimo, maximo = masc_min, masc_max # usa a faixa de referência para homens
        elif faixa and faixa.start() < _JANELA:
            minimo, maximo = _parse_valor(faixa.group(1)), _parse_valor(faixa.group(2)) # usa a faixa de referência encontrada
        elif menor and menor.start() < _JANELA:
            maximo = _parse_valor(menor.group(1)) # usa o valor máximo permitido
        elif maior and maior.start() < _JANELA:
            minimo = _parse_valor(maior.group(1)) # usa o valor mínimo permitido
        else:
            interpretavel = False # marca como não interpretável automaticamente se não houver referência próxima

        resultados.append({
            "parametro": nome, "valor": valor, "unidade": unidade,
            "valor_min": minimo, "valor_max": maximo,
            "interpretavel_automaticamente": interpretavel,
        }) # adiciona o resultado extraído à lista

    return resultados # devolve a lista de resultados encontrados no bloco


def avaliar_resultado(r: dict) -> dict:
    if not r["interpretavel_automaticamente"]:
        return {**r, "status": "indefinido",
                "mensagem": ("Não foi possível interpretar automaticamente o valor de referência "
                              "deste exame. Consulte um profissional para interpretar este resultado.")} # se não for possível interpretar automaticamente, marca como indefinido e adiciona uma mensagem explicativa

    status = "normal"
    mensagem = f"{r['parametro']} dentro do valor de referência, sem sinais de alteração :)"

    if r["valor_min"] is not None and r["valor"] < r["valor_min"]:
        status = "abaixo"
        mensagem = f"{r['parametro']} abaixo do valor de referência. Procure um médico." # marca como abaixo do valor de referência
    elif r["valor_max"] is not None and r["valor"] > r["valor_max"]:
        status = "acima"
        mensagem = f"{r['parametro']} acima do valor de referência. Procure um médico." # marca como acima do valor de referência

    return {**r, "status": status, "mensagem": mensagem} # devolve o resultado com status e mensagem interpretados


def analisar_laudo(conteudo_bytes: bytes, genero_usuario: str) -> list[dict]:
    texto = extrair_texto_pdf(conteudo_bytes) # extrai o texto do PDF para análise
    resultados = []
    for bloco in dividir_por_exame(texto): # percorre cada bloco de exame separado
        for r in extrair_resultados_do_bloco(bloco, genero_usuario): # extrai os resultados de cada bloco
            resultados.append(avaliar_resultado(r)) # avalia e junta todos os resultados em uma lista final
    return resultados # devolve a lista final de resultados analisados