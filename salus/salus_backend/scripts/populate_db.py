import csv
from app.db.database import SessionLocal
from app.models.knowledge import Symptom, Condition, SymptomCondition

# garante que cada sintoma seja armazenado apenas uma vez na tabela
def buscar_ou_criar_sintoma(db, nome: str) -> Symptom:
    nome = nome.strip().lower()
    sintoma = db.query(Symptom).filter(Symptom.name == nome).first()
    if sintoma:
        return sintoma
    sintoma = Symptom(name=nome)
    db.add(sintoma)
    db.flush()  # já gera o id sem precisar commitar ainda
    return sintoma


def run():
    db = SessionLocal() # cria uma novase ssão do db

    if db.query(Condition).count() > 0: # quantos registros existem na tabela de conditions
        print("Base já populada.")
        db.close()
        return

    with open("data/conditions_seed.csv", encoding="utf-8") as f: # abre o .csv 
        table = csv.DictReader(f, delimiter=";") # em mode leitura
        contador = 0 # contador de doenças
        for linha in table: # cada linha na tabela
            condicao = Condition(
                name=linha["name"].strip(),
                cid10=linha["cid10"].strip(),
                informative_message=linha["informative_message"].strip(),
                manchester_color=linha["manchester_color"].strip(),
                manchester_label=linha["manchester_label"].strip(),
            )
            db.add(condicao) # adiciona a doença na no db
            db.flush() # gera oi id da doença imediatamente

            for par in linha["symptoms"].split("|"): # quebra a linah de sintomas (ex: dor nas costas:0.43|calafrios:0.43|...
                nome_sintoma, peso = par.split(":") # a cada par fazemos nome do sintoma e peso (ex: dor nas costas 0.43
                sintoma = buscar_ou_criar_sintoma(db, nome_sintoma) # busca se o sintoma já foi cadastrado
                db.add(SymptomCondition(
                    symptom_id=sintoma.id, # id do sintoma atual
                    condition_id=condicao.id, # id da doença atual
                    weight=float(peso), # peso
                ))
            contador += 1 # incrementa o contador

    db.commit() # 
    db.close()
    print(f"{contador} condições carregadas com sucesso.") # printa se deu tudo certo


if __name__ == "__main__":
    run()