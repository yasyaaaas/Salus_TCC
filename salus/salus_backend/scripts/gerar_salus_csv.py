# 2_gerar_csv_salus.py
import pandas as pd
from deep_translator import MyMemoryTranslator
import time

CAMINHO_AGRUPADO = "data/clustered_dataset.csv"
CAMINHO_SAIDA = "data/conditions_seed.csv"
CAMINHO_CACHE_TRADUCAO = "data/cache_traducao.csv"

LIMIAR_FREQUENCIA = 0.1
MAX_SINTOMAS = 15


def traduzir_sintomas(lista_sintomas):
    # Tenta carregar cache existente
    cache = {}
    try:
        df_cache = pd.read_csv(CAMINHO_CACHE_TRADUCAO, sep=";")
        cache = dict(zip(df_cache["original"], df_cache["traduzido"]))
        print(f"Cache carregado: {len(cache)} traduções já existentes.")
    except FileNotFoundError:
        print("Nenhum cache encontrado. Será criado um novo.")

    tradutor = MyMemoryTranslator(source="en-US", target="pt-BR")
    traducoes = dict(cache)
    total = len(lista_sintomas)

    for i, sintoma in enumerate(lista_sintomas, start=1):
        if sintoma in cache:
            continue  # já está no cache, pula

        sucesso = False
        for tentativa in range(1, 4):
            try:
                traduzido = tradutor.translate(sintoma)
                traducoes[sintoma] = traduzido
                print(f"[{i}/{total}] '{sintoma}' -> '{traduzido}'")
                sucesso = True
                break
            except Exception as e:
                espera = 2 ** tentativa
                print(f"[{i}/{total}] Tentativa {tentativa} falhou. Esperando {espera}s...")
                time.sleep(espera)

        if not sucesso:
            print(f"[{i}/{total}] Desistindo de '{sintoma}'. Mantendo original.")
            traducoes[sintoma] = sintoma

        time.sleep(0.5)

        # Salva cache parcial a cada 10 traduções NOVAS
        if i % 10 == 0:
            df_cache = pd.DataFrame(
                list(traducoes.items()), columns=["original", "traduzido"]
            )
            df_cache.to_csv(CAMINHO_CACHE_TRADUCAO, sep=";", index=False)
            print(f"  → Cache parcial salvo ({len(traducoes)} traduções).")

    # Salva o cache final (com TUDO: antigo + novo)
    df_cache = pd.DataFrame(
        list(traducoes.items()), columns=["original", "traduzido"]
    )
    df_cache.to_csv(CAMINHO_CACHE_TRADUCAO, sep=";", index=False)

    return traducoes


print("=" * 60)
print("ETAPA 1: Traduzindo sintomas (MyMemory)")
print("=" * 60)

df = pd.read_csv(CAMINHO_AGRUPADO, index_col=0)
totais = df["_total_amostras"]
df = df.drop(columns=["_total_amostras"])

print(f"Doenças: {len(df)}")
print(f"Sintomas: {len(df.columns)}")

mapa_traducao = traduzir_sintomas(list(df.columns))
df = df.rename(columns=mapa_traducao)

mapa_doencas = traduzir_sintomas(list(df.index))
df = df.rename(index=mapa_doencas)

totais = totais.rename(index=mapa_doencas)

print("\nTradução concluída.")

print("\n" + "=" * 60)
print("ETAPA 2: Gerando CSV no formato do Salus")
print("=" * 60)

linhas_salus = []

for doenca in df.index:
    linha = df.loc[doenca]
    total = totais[doenca]
    frequencias = linha / total
    relevantes = frequencias[frequencias >= LIMIAR_FREQUENCIA]

    if len(relevantes) == 0:
        continue

    relevantes = relevantes.sort_values(ascending=False).head(MAX_SINTOMAS)

    sintomas_str = "|".join(
        f"{sintoma.strip()}:{round(peso, 2)}"
        for sintoma, peso in relevantes.items()
    )

    linhas_salus.append({
        "name": doenca,
        "cid10": "",
        "manchester_color": "",
        "manchester_label": "",
        "informative_message": "",
        "symptoms": sintomas_str,
    })

df_saida = pd.DataFrame(linhas_salus)
df_saida.to_csv(CAMINHO_SAIDA, sep=";", index=False)

print(f"\nArquivo salvo em: {CAMINHO_SAIDA}")
print(f"Total de doenças: {len(df_saida)}")
print("\nExemplo de linha gerada:")
print(df_saida.iloc[0].to_string())