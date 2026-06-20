# legado-mirror — Banco de Dados de Passagem

Camada intermediária da solução de modernização.
Recebe os JSONs gerados pelo Java 7 e os disponibiliza para a API Spring Boot.

## Estrutura

```
legado-mirror/
├── .env                        # Credenciais (não versionado)
├── .gitignore
├── docker-compose.yml
├── json-input/                 # Pasta compartilhada: Java 7 grava, Spring Boot lê
│   ├── imob_dados.json
│   ├── nfse_dados.json
│   └── cda_dados.json
├── data/
│   └── postgres/               # Volume de persistência do PostgreSQL (não versionado)
└── postgres/
    └── init/
        └── 01_init.sql         # Criação do schema e tabelas (roda só na 1ª subida)
```

## Pré-requisitos

- Docker Desktop para Windows com integração WSL 2 habilitada
- WSL 2 rodando (Ubuntu recomendado)

## Setup inicial

### 1. Configure o .env

Edite o arquivo `.env` e ajuste `JSON_INPUT_PATH` para o mesmo diretório
configurado como `output.dir` no `database.properties` do projeto Java 7.

Exemplo: se o Java 7 grava em `C:\extracao\output`, coloque:
```
JSON_INPUT_PATH=C:/extracao/output
```

> O Docker Desktop converte automaticamente o path do Windows para WSL2.

### 2. Suba o container

```bash
# Na raiz deste projeto (onde está o docker-compose.yml)
docker compose up -d
```

Na **primeira execução**, o PostgreSQL roda automaticamente o `01_init.sql`,
criando o schema `bicabedelo` e todas as tabelas.

### 3. Verifique a saúde do container

```bash
docker compose ps
# STATUS deve ser: Up (healthy)
```

### 4. Confirme as tabelas

```bash
docker exec -it legado-mirror-db \
  psql -U postgres -d legado_mirror \
  -c "\dt bicabedelo.*"
```

Saída esperada:
```
              List of relations
  Schema    |      Name       | Type  |  Owner
------------+-----------------+-------+----------
 bicabedelo | cda_dados       | table | postgres
 bicabedelo | imob_dados      | table | postgres
 bicabedelo | importacao_log  | table | postgres
 bicabedelo | nfse_dados      | table | postgres
```

## Operação diária

O container está configurado com `restart: unless-stopped` — sobe
automaticamente com o Docker Desktop e sobrevive a reinicializações da máquina.

## Comandos úteis

```bash
# Parar o container sem remover dados
docker compose stop

# Subir novamente
docker compose start

# Ver logs do PostgreSQL
docker compose logs -f postgres

# Acessar o psql diretamente
docker exec -it legado-mirror-db psql -U postgres -d legado_mirror

# Destruir tudo (inclusive os dados) — use com cuidado
docker compose down -v
```

## Reset do banco (recriar tabelas do zero)

Se precisar recriar as tabelas durante o desenvolvimento:

```bash
docker exec -it legado-mirror-db \
  psql -U postgres -d legado_mirror \
  -c "DROP SCHEMA bicabedelo CASCADE; CREATE SCHEMA bicabedelo;"

docker exec -it legado-mirror-db \
  psql -U postgres -d legado_mirror \
  -f /docker-entrypoint-initdb.d/01_init.sql
```
