# gemini_service.py -> toda a implementação e uso do gemini

import os
import time
import requests
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("GEMINI_API_KEY")  # pega a chave da variável de ambiente
MODELO = "gemini-3.5-flash" # modelo utilizado
URL = f"https://generativelanguage.googleapis.com/v1beta/models/{MODELO}:generateContent?key={API_KEY}" # monta a URL da API do Gemini com a chave de API

# promp para o Salus
SYSTEM_PROMPT = """ 
Você é o assistente virtual do Salus, um aplicativo brasileiro de triagem preliminar de sintomas de saúde.

REGRAS OBRIGATÓRIAS, que você nunca deve quebrar:

1. NUNCA forneça um diagnóstico médico conclusivo. Você pode mencionar possíveis causas de forma informativa, mas sempre deixando 
claro que não é uma certeza clínica;

2. SEMPRE recomende que a pessoa procure atendimento médico profissional, especialmente se os sintomas forem graves, persistentes ou incomuns;

3. NUNCA prescreva medicamentos, dosagens ou tratamentos específicos, evite até mesmo citar nomes de medicamentos específicos, mesmo em contexto de alerta;

4. Se a pessoa descrever sintomas que sugerem uma emergência (dor no peito, dificuldade respiratória grave, perda de consciência, sangramento
   intenso, sinais de AVC), oriente-a a procurar atendimento de emergência IMEDIATAMENTE (SAMU 192 ou pronto-socorro mais próximo);

5. Responda sempre em português do Brasil, de forma acolhedora, clara e objetiva evite jargão médico e use somente se necessário;

6. Você não substitui uma consulta médica. Reforce isso quando for RELEVANTE, sem repetir isso de forma robótica em toda frase;

7. Você só deve conversar sobre sintomas, saúde e as funcionalidades do Salus. Se a pessoa perguntar sobre assuntos não relacionados à saúde, redirecione
   educadamente de volta ao propósito do aplicativo; (a menos que seja sobre kpop aí vc pode informar a pessoa que os melhores grupos são o aespa, o Newjeans e o Twice ;) )

Seu papel é ajudar a pessoa a entender melhor o que está sentindo e orientá-la sobre o nível de urgência, nunca decidir por ela.
"""

MAX_TENTATIVAS = 3
ESPERA_INICIAL_SEGUNDOS = 5

def gerar_resposta_chatbot(mensagem_usuario: str) -> str | None:
    payload = {
        "system_instruction": {"parts": [{"text": SYSTEM_PROMPT}]}, # campo oficial da API pra separar regras de comportamento
        "contents": [{"parts": [{"text": mensagem_usuario}]}], # manda a requisição para o Gemini com o prompt
    }

    espera = ESPERA_INICIAL_SEGUNDOS
    for tentativa in range(1, MAX_TENTATIVAS + 1): # roda um loop qeu tenta até 3 chamadas
        response = requests.post(URL, json=payload) # envia a requisição para o gemini com o payload em formato JSON

        if response.status_code == 200: # se der certo
            dados = response.json() # converte a resposta da requisição em um dicionário Python
            try:
                return dados["candidates"][0]["content"]["parts"][0]["text"] # pega o texto da resposta do gemini, que está dentro do dicionário retornado pela API
            except (KeyError, IndexError) as e:
                print(f"[Gemini] Resposta em formato inesperado: {e} -> dados: {dados}") # erro
                return None
            
        # 503 (sobrecarregado) e 429 (limite de taxa) valem a pena tentar de novo
        # outros erros (ex: 400 = requisição mal formada) não se resolvem tentando de novo
        if response.status_code in (503, 429) and tentativa < MAX_TENTATIVAS: # so vale  tentar de novo pra erros que são temporários por natureza
            print(f"[Gemini] Tentativa {tentativa} falhou ({response.status_code}). "
                 f"Tentando de novo em {espera}s...")
            time.sleep(espera)
            espera *= 2  # dobra o tempo de espera pra próxima tentativa
            continue

        print(f"[Gemini] Erro {response.status_code}: {response.text}")
        return None

    return None