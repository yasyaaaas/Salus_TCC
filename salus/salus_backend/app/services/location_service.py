import requests
from geopy.distance import geodesic

OVERPASS_URL = "https://overpass-api.de/api/interpreter" # permite fazer consultas à API do OpenStreetMap para obter os locais geográficos
OSRM_URL = "https://router.project-osrm.org/route/v1/driving" # permite calcular rotas e distâncias entre coordenadas geográficas usando o serviço OSRM (Open Source Routing Machine)

RAIO_PADRAO_METROS = 5000
USER_AGENT = "Salus-TCC (https://github.com/yasyaaaas/Salus_TCC)" # define o user-agent para as requisições HTTP, identificando o aplicativo e fornecendo um link para mais informações


def _distancia_km(lat1, lon1, lat2, lon2) -> float:
    """Distância em linha reta entre dois pontos usando geopy"""
    ponto1 = (lat1, lon1) # ponto 1 é a coordenada do usuário
    ponto2 = (lat2, lon2) # ponto 2 é a coordenada da unidade de saúde
    return geodesic(ponto1, ponto2).kilometers # calcula a distância em quilômetros entre os dois pontos usando a biblioteca geopy, que leva em conta a curvatura da Terra

def _classificar_tipo(tags: dict) -> tuple[str, int]: # recebe tags de um elemento do OpenStreetMap e retorna o tipo de unidade de saúde e sua prioridade
    """Classifica a unidade e define prioridade, a heurística baseada nas tags do OpenStreetMap"""
    # pega as tags relevantes
    amenity = tags.get("amenity", "")
    emergency = tags.get("emergency", "")
    healthcare = tags.get("healthcare", "")
    nome = tags.get("name", "").upper()

    # Pronto atendimento / emergência (prioridade máxima)
    if emergency == "yes" or "UPA" in nome or "PRONTO SOCORRO" in nome:
        return "pronto_atendimento", 0

    # Hospital (prioridade máxima também)
    if amenity == "hospital":
        return "hospital", 0

    # UBS / posto de saúde (prioridade média)
    if (
        amenity == "clinic"
        or healthcare == "clinic"
        or "UBS" in nome
        or "POSTO DE SAUDE" in nome
        or "POSTO DE SAÚDE" in nome
        or "CENTRO DE SAUDE" in nome
        or "CENTRO DE SAÚDE" in nome
    ):
        return "ubs", 1

    # prioridade baixa para outros tipos de unidades de saúde
    return "outro", 2


def buscar_unidades_proximas(lat: float, lon: float, raio_metros: int = RAIO_PADRAO_METROS) -> list[dict]:
    """Busca unidades de saúde próximas usando Overpass API e retorna lista ordenada por prioridade e distância"""
    query = f"""
    [out:json][timeout:25];
    (
      node["amenity"="hospital"](around:{raio_metros},{lat},{lon});
      way["amenity"="hospital"](around:{raio_metros},{lat},{lon});
      node["amenity"="clinic"](around:{raio_metros},{lat},{lon});
      way["amenity"="clinic"](around:{raio_metros},{lat},{lon});
      node["healthcare"](around:{raio_metros},{lat},{lon});
      way["healthcare"](around:{raio_metros},{lat},{lon});
    );
    out center tags;
    """

    headers = {"User-Agent": USER_AGENT} # define o cabeçalho da requisição HTTP com o user-agent 
    resposta = requests.post(OVERPASS_URL, data={"data": query}, headers=headers, timeout=30) # faz a requisição POST para a API do Overpass com a query definida
    # envia os dados e o cabeçalho, e define um tempo limite de 30 segundos
    resposta.raise_for_status() # levanta uma exceção se a resposta da API não for bem-sucedida (código de status diferente de 200)
    elementos = resposta.json().get("elements", []) # obtém os elementos retornados pela API, que representam as unidades de saúde encontradas

    unidades = [] # lista para armazenar as unidades de saúde encontradas
    vistos = set()  # evita duplicatas (node e way podem se sobrepor)

    for element in elementos: # percorre cada elemento retornado pela API do Overpass
        tags = element.get("tags", {}) # pega as tags associadas ao elemento, que contêm informações sobre o tipo de unidade de saúde, nome, endereço, etc.
        nome = tags.get("name")
        if not nome:
            continue  # ignora unidades sem nome cadastrado

        if element["type"] == "node": # node -> usa as coordenadas do próprio nó
            unidade_lat, unidade_lon = element["lat"], element["lon"] # se o elemento for um nó, pega as coordenadas diretamente do nó
        else:  # way -> usa o centro geométrico calculado pelo "out center"
            centro = element.get("center")
            if not centro:
                continue
            unidade_lat, unidade_lon = centro["lat"], centro["lon"] # se o elemento for um caminho (way), pega as coordenadas do centro geométrico calculado pelo Overpass

        chave = (round(unidade_lat, 5), round(unidade_lon, 5), nome) # arredonda as coordenadas para evitar duplicatas
        if chave in vistos:
            continue # se já viu a chave antes, ignora para evitar duplicatas
        vistos.add(chave)

        tipo, prioridade = _classificar_tipo(tags) # classifica o tipo de unidade de saúde e define a prioridade com base nas tags do OpenStreetMap
        distancia = _distancia_km(lat, lon, unidade_lat, unidade_lon) # calcula a distância em quilômetros entre o usuário e a unidade de saúde

        # Monta endereço a partir das tags disponíveis
        endereco_parts = []
        if tags.get("addr:street"):
            endereco_parts.append(tags["addr:street"]) # adiciona o nome da rua ao endereço se disponível
        if tags.get("addr:housenumber"):
            endereco_parts.append(tags["addr:housenumber"]) # adiciona o número da casa ao endereço se disponível
        if tags.get("addr:city"):
            endereco_parts.append(tags["addr:city"]) # adiciona a cidade ao endereço se disponível
        endereco = ", ".join(endereco_parts) if endereco_parts else None

        unidades.append({ # adiciona a unidade de saúde à lista de resultados
            "nome": nome,
            "tipo": tipo,
            "latitude": unidade_lat,
            "longitude": unidade_lon,
            "endereco": endereco,
            "distancia_km": round(distancia, 2),
            "_prioridade": prioridade,
        })

    # Ordena por prioridade (menor = mais urgente) e depois por distância
    unidades.sort(key=lambda u: (u["_prioridade"], u["distancia_km"]))
    for u in unidades:
        del u["_prioridade"]

    return unidades[:15] # retorna apenas as 15 unidades mais próximas e relevantes, ordenadas por prioridade e distância


def calcular_rota(origem_lat: float, origem_lon: float, destino_lat: float, destino_lon: float) -> dict | None:
    """Calcula a rota entre dois pontos usando OSRM e retorna distância, duração estimada e coordenadas do trajeto"""
    # OSRM espera as coordenadas como longitude,latitude (ordem inversa)
    url = f"{OSRM_URL}/{origem_lon},{origem_lat};{destino_lon},{destino_lat}" # monta a URL para a requisição à API do OSRM, incluindo as coordenadas de origem e destino
    params = {"overview": "full", "geometries": "geojson"} # define os parâmetros da requisição, pedindo o trajeto completo e o formato GeoJSON para as coordenadas do trajeto
    headers = {"User-Agent": USER_AGENT}

    resposta = requests.get(url, params=params, headers=headers, timeout=15) # faz a requisição GET para a API do OSRM com os parâmetros definidos e o cabeçalho, e define um tempo limite de 15 segundos
    resposta.raise_for_status()
    dados = resposta.json()

    if dados.get("code") != "Ok" or not dados.get("routes"): # verifica se a resposta da API do OSRM foi bem-sucedida e se há rotas disponíveis
        return None

    rota = dados["routes"][0] # pega a primeira rota disponível, que é a rota mais rápida calculada pelo OSRM
    coordenadas = [
        {"latitude": lat, "longitude": lon}
        for lon, lat in rota["geometry"]["coordinates"]
    ]

    return { # retorna um dicionário com a distância em quilômetros, duração estimada em minutos e as coordenadas do trajeto
        "distancia_km": round(rota["distance"] / 1000, 2),
        "duracao_min": round(rota["duration"] / 60),
        "coordenadas": coordenadas,
    }