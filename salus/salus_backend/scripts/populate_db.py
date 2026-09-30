import csv
from app.db.database import SessionLocal, engine, Base
from app.models.knowledge import Symptom, Condition, SymptomCondition


def buscar_ou_criar_sintoma(db, nome: str) -> Symptom:
    nome = nome.strip().lower()
    sintoma = db.query(Symptom).filter(Symptom.name == nome).first()
    if sintoma:
        return sintoma
    sintoma = Symptom(name=nome)
    db.add(sintoma)
    db.flush()
    return sintoma


def run():
    # Cria as tabelas se ainda não existirem (usa o metadata dos modelos)
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()

    if db.query(Condition).count() > 0:
        print("Base já populada.")
        db.close()
        return

    with open("data/conditions_seed.csv", encoding="utf-8") as f:
        table = csv.DictReader(f, delimiter=";")
        contador = 0
        for linha in table:
            condicao = Condition(
                name=linha["name"].strip(),
                cid10=linha["cid10"].strip(),
                manchester_color=linha["manchester_color"].strip(),
                manchester_label=linha["manchester_label"].strip(),
            )
            db.add(condicao)
            db.flush()

            for par in linha["symptoms"].split("|"):
                par = par.strip()
                if not par or ":" not in par:
                    continue
                nome_sintoma, peso = par.split(":", 1)
                sintoma = buscar_ou_criar_sintoma(db, nome_sintoma)
                db.add(SymptomCondition(
                    symptom_id=sintoma.id,
                    condition_id=condicao.id,
                    weight=float(peso),
                ))
            contador += 1

    db.commit()
    db.close()
    print(f"{contador} condições carregadas com sucesso.")


if __name__ == "__main__":
    run()