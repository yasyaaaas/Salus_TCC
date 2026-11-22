-- Banco de Dados: PostgreSQL 16
-- Projeto: Salus - TCC Yasmin Viegas
-- Mapeamento exato gerado a partir dos modelos SQLAlchemy

CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- Necessário para gerar UUIDs no PostgreSQL

-- Tabela de Usuários
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    age INTEGER NOT NULL,
    weight_kg FLOAT NOT NULL,
    height_cm INTEGER NOT NULL,
    gender VARCHAR(20) NOT NULL,
    avatar VARCHAR(50) NOT NULL DEFAULT 'Navely.png'
);

-- Tabela de Sintomas
CREATE TABLE symptoms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(120) UNIQUE NOT NULL
);

-- Tabela de Condições (Doenças)
CREATE TABLE conditions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    cid10 VARCHAR(10),
    manchester_color VARCHAR(20) NOT NULL,
    manchester_label VARCHAR(80) NOT NULL
);

-- Tabela de Associação N:N com o peso (Sintoma <-> Condição)
CREATE TABLE symptom_condition (
    id SERIAL PRIMARY KEY,
    symptom_id INTEGER NOT NULL REFERENCES symptoms(id) ON DELETE CASCADE,
    condition_id INTEGER NOT NULL REFERENCES conditions(id) ON DELETE CASCADE,
    weight FLOAT DEFAULT 0.5
);

-- Tabela de Mensagens do Chat (Histórico)
CREATE TABLE chat_messages (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mensagem_usuario TEXT NOT NULL,
    resposta_chatbot TEXT NOT NULL,
    manchester_color VARCHAR(20),
    manchester_label VARCHAR(80),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Análise de Exames (Salva o resultado em JSON)
CREATE TABLE exam_analyses (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    nome_arquivo VARCHAR(255),
    resultados JSON NOT NULL, -- Armazena a lista de dicionários (parâmetro, valor, status, etc.)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para otimização de busca
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_symptoms_name ON symptoms(name);
CREATE INDEX idx_conditions_cid10 ON conditions(cid10);