# agrupar_por_doenca.py
# Lê o CSV original do Mendeley e agrupa por doença,
# contando quantas vezes cada sintoma aparece em cada doença.

import pandas as pd

CAMINHO_ORIGINAL = "data/Disease_and_symptoms_dataset_original.csv"
CAMINHO_SAIDA = "data/clustered_dataset.csv"

print("Lendo o CSV original...")
df = pd.read_csv(CAMINHO_ORIGINAL)

# A primeira coluna é a doença; as demais são sintomas
coluna_doenca = df.columns[0]
colunas_sintomas = df.columns[1:]

print(f"Total de amostras: {len(df)}")
print(f"Doenças únicas: {df[coluna_doenca].nunique()}")
print(f"Sintomas: {len(colunas_sintomas)}")

# Agrupa por doença e soma as colunas de sintomas (quantos 1s tem em cada)
print("\nAgrupando por doença...")
agrupado = df.groupby(coluna_doenca)[colunas_sintomas].sum()

# Adiciona uma coluna com o total de amostras por doença
agrupado["_total_amostras"] = df.groupby(coluna_doenca).size()

# Salva o resultado
agrupado.to_csv(CAMINHO_SAIDA)
print(f"\nArquivo salvo em: {CAMINHO_SAIDA}")
print(f"Total de doenças no agrupado: {len(agrupado)}")