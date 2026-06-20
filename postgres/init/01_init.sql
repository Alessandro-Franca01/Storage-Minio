-- =============================================================================
-- 01_init.sql
-- Executado automaticamente pelo PostgreSQL na primeira inicialização
-- do container (docker-entrypoint-initdb.d).
--
-- O banco "legado_mirror" já existe (criado pela variável POSTGRES_DB).
-- Este script apenas cria o schema e as tabelas.
--
-- Encoding: UTF-8 garantido pelo POSTGRES_INITDB_ARGS no docker-compose.
-- =============================================================================

-- CREATE SCHEMA IF NOT EXISTS name_schema;

-- -----------------------------------------------------------------------------
-- TABELAS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS name_schema.name_table (
    id         INTEGER PRIMARY KEY,
    campo1     TEXT,
    campo2     TEXT,
    campo3     TEXT,
    campo3     TEXT,
    campo4     TEXT,
    -- Metadado de controle: data/hora em que o registro foi importado
    criada_em   TIMESTAMP DEFAULT NOW()
);
