# Salus Backend

API RESTful desenvolvida em **FastAPI** (Python). Responsável por autenticação, moderação ética do chatbot, análise de exames laboratoriais e busca de unidades de saúde.

## Estrutura do projeto

```bash
salus_backend/
├── app/
│ ├── core/
│ │ └── security.py # Hash de senhas (bcrypt) e criação/validação de tokens JWT
│ ├── db/
│ │ └── database.py # Conexão com o PostgreSQL (SQLAlchemy)
│ ├── models/ # Modelos das tabelas do banco
│ │ ├── user.py # Tabela de usuários
│ │ ├── knowledge.py # Tabelas de sintomas, condições e associações
│ │ ├── chat.py # Tabela do histórico de conversas
│ │ └── exam.py # Tabela das análises de exames
│ ├── schemas/
│ │ └── schemas.py # Moldes de validação (Pydantic) -> o que entra e sai da API
│ ├── services/ # Lógica de negócio
│ │ ├── chat_services.py # Orquestra o chatbot (Gemini + base estruturada)
│ │ ├── gemini_service.py # Integração com a API do Google Gemini
│ │ ├── knowledge_service.py # Busca sintomas e ranqueia condições médicas
│ │ ├── exam_service.py # Extrai e interpreta exames de PDFs
│ │ └── location_service.py # Busca unidades de saúde e calcula rotas
│ └── auth_deps.py # Dependência que exige token JWT nas rotas protegidas
├── data/
│ └── conditions_seed.csv # Base de sintomas, condições e níveis de urgência
├── scripts/
│ └── populate_db.py # Popula o banco com os dados do CSV
├── main.py # Ponto de entrada da API (rotas e configuração)
├── docker-compose.yml # Configuração do PostgreSQL em contêiner
├── requirements.txt # Dependências do projeto
└── .env.example # Exemplo de variáveis de ambiente
```

## Como rodar

```bash
# Clone o repositório
git clone https://github.com/yasyaaaas/Salus_TCC.git
cd Salus_TCC/salus_backend

# Crie e ative o ambiente virtual
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Instale as dependências
pip install -r requirements.txt

# Configure o .env
cp .env.example .env

# Suba o banco de dados
docker-compose up -d

# Popule a base de conhecimento
python -m scripts.populate_db

# Rode o servidor
uvicorn main:app --reload
A API estará disponível em http://localhost:8000. Documentação interativa em /docs.
```

## Tecnologias
- Python + FastAPI
- PostgreSQL (via Docker)
- SQLAlchemy
- Google Gemini 3.5 Flash
- PyMuPDF
- Overpass API + OSRM
- JWT + bcrypt
