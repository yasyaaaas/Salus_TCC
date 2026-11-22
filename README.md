# Salus

**Aplicativo mobile de primeiro atendimento digital desenvolvido como Trabalho de Conclusão de Curso (TCC) na PUC Minas.**

O Salus permite que o usuário relate sintomas em linguagem natural, envie laudos laboratoriais para análise e encontre unidades de saúde próximas sem substituir o diagnóstico médico profissional.

Desenvolvido por:
Autora: Yasmin Cassemiro Viegas <br>
Orientador: Prof. Ilo Amy Saldanha Rivero <br>
Ciência da Computação - PUC Minas 2026

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.x-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql)](https://www.postgresql.org)

---

## Sumário

- [Sobre o projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Requisitos](#requisitos)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Como rodar](#como-rodar)
- [Referências](#referências)

---

## Sobre o projeto

Diante do crescente uso da inteligência artificial para esclarecer dúvidas sobre saúde, surge a necessidade de criar meios digitais mais confiáveis e fundamentados em princípios éticos. O **Salus** propõe uma ferramenta de primeiro atendimento digital que busca preencher a lacuna de comunicação entre paciente e profissional de saúde no cenário brasileiro.

**Diferencial:** mecanismos de moderação ética das respostas da IA, garantindo que nenhum fluxo da aplicação resulte em diagnóstico médico conclusivo.

**Modelagem de Dados:** A estrutura do banco de dados PostgreSQL, incluindo o Diagrama de Entidade-Relacionamento (DER) e o script de criação das tabelas (`schema.sql`), está documentada na pasta `salus_backend/data/` e foi detalhada no texto do TCC (Seção 3.2).

---

## Funcionalidades

- **Chatbot de triagem de sintomas:** relato em linguagem natural com moderação ética e classificação de urgência pela Escala de Manchester
- **Análise de exames laboratoriais:** extração de texto de PDFs e identificação de valores alterados
- **Recomendação de unidades de saúde:** busca por hospitais, UBS e UPAs próximos, com cálculo de rota
- **Perfil do usuário:** dados antropométricos, IMC e histórico de interações

---

## Requisitos

### Requisitos Funcionais (RF)

#### Módulo de Autenticação e Perfil

| Código | Descrição |
| :--- | :--- |
| RF01 | O sistema deve permitir ao usuário realizar cadastro com e-mail e senha |
| RF02 | O sistema deve permitir ao usuário realizar login na plataforma |
| RF03 | O sistema deve permitir ao usuário visualizar e editar seus dados de perfil |

#### Módulo de Chatbot de Sintomas

| Código | Descrição |
| :--- | :--- |
| RF04 | O sistema deve permitir ao usuário relatar sintomas em linguagem natural por meio de uma interface de chat |
| RF05 | O sistema deve retornar orientações informativas com base nos sintomas relatados, sem emitir diagnóstico conclusivo |
| RF06 | O sistema deve indicar o nível de urgência associado aos sintomas relatados utilizando a Escala de Manchester |
| RF07 | O sistema sempre deve recomendar a busca por atendimento profissional |
| RF08 | O sistema deve armazenar o histórico de conversas do usuário |

#### Módulo de Análise de Exames

| Código | Descrição |
| :--- | :--- |
| RF09 | O sistema deve permitir ao usuário enviar o laudo laboratorial em formato PDF |
| RF10 | O sistema deve extrair os parâmetros, valor, unidade e referência presentes no laudo em PDF por meio de leitura direta de texto |
| RF11 | O sistema deve identificar os valores extraídos do laudo |
| RF12 | O sistema deve apresentar ao usuário mensagens informativas sobre os valores alterados, sem emitir diagnóstico conclusivo |
| RF13 | O sistema deve orientar o usuário a buscar avaliação profissional caso o valor de referência de um exame não seja passível de interpretação automática |
| RF14 | O sistema deve armazenar o histórico das análises de exames executadas pelo usuário |

#### Módulo de Localização

| Código | Descrição |
| :--- | :--- |
| RF15 | O sistema deve identificar a localização atual do usuário por meio do GPS do dispositivo |
| RF16 | O sistema deve recomendar unidades de saúde próximas ao usuário, separando-as por preferência do usuário |
| RF17 | O sistema deve permitir ao usuário visualizar a rota até a unidade de saúde selecionada |

### Requisitos Não Funcionais (RNF)

| Código | Descrição |
| :--- | :--- |
| RNF01 | O sistema deve ser desenvolvido para plataformas Android e iOS a partir de uma única base de código em Flutter |
| RNF02 | O sistema deve proteger os dados sensíveis dos usuários em conformidade com a LGPD |
| RNF03 | O sistema não deve compartilhar dados pessoais ou clínicos dos usuários com terceiros |
| RNF04 | O sistema deve utilizar comunicação cifrada via HTTPS em todas as requisições |
| RNF05 | O sistema deve apresentar interface em língua portuguesa |
| RNF06 | O sistema não deve emitir diagnóstico médico em nenhum fluxo da aplicação |
| RNF07 | O sistema deve estar disponível para acesso contínuo, com hospedagem em ambiente de nuvem |
| RNF08 | O sistema deve armazenar os dados antropométricos do usuário (idade, gênero, altura e peso) para o cálculo do IMC |

---

## Arquitetura

O Salus é composto por três camadas principais:

- **Frontend:** aplicativo mobile em Flutter
- **Backend:** API RESTful em FastAPI (Python)
- **Serviços externos:** PostgreSQL, Gemini (chatbot), Overpass API (unidades de saúde) e OSRM (rotas)

## Tecnologias

| Camada | Tecnologia |
| :--- | :--- |
| Frontend | Flutter, Dart |
| Backend | Python, FastAPI, SQLAlchemy |
| Banco de Dados | PostgreSQL (Docker) |
| IA | Google Gemini 3.5 Flash |
| Localização | Overpass API, OSRM, OpenStreetMap |
| Análise de PDF | PyMuPDF |
| Autenticação | JWT, bcrypt |

---

## Como rodar

### Pré-requisitos

- Flutter SDK >= 3.x
- Dart >= 3.x
- Python >= 3.11
- Docker + Docker Compose
- Emulador Android/iOS ou dispositivo físico

### Backend

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

# Configure o .env (veja .env.example)
cp .env.example .env

# Suba o banco de dados
docker-compose up -d

# Popule a base de conhecimento
python -m scripts.populate_db

# Rode o servidor
uvicorn main:app --reload

A API estará disponível em http://localhost:8000. Documentação interativa em /docs.
```
### Frontend
```bash
cd Salus_TCC/salus

# Instale as dependências
flutter pub get

# Rode o app
flutter run
```

## Referências

O referencial teórico completo, incluindo as citações utilizadas no desenvolvimento deste trabalho, está disponível no texto do TCC.

Para os requisitos funcionais e não funcionais detalhados, consulte a seção Requisitos deste README.
