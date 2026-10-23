"""
backend/db.py
Responsabilidade única: abrir e fechar conexão com o PostgreSQL.

Este arquivo NÃO sabe o que é um "plano" ou uma "demanda" — isso é
responsabilidade de backend/models/. Separar assim significa que, se um
dia o projeto trocar de banco (ex.: MySQL), só este arquivo muda.
"""
from pathlib import Path

import psycopg2
import psycopg2.extras

# Raiz do projeto (a pasta acima de backend/)
BASE_DIR = Path(__file__).resolve().parent.parent
DB_DIR = BASE_DIR / "database"

# AJUSTE aqui com os dados do seu PostgreSQL local.
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "smartnexus",
    "user": "postgres",
    "password": "postgres",
}


def get_db():
    """Abre uma conexão nova com o PostgreSQL.
    cursor_factory=RealDictCursor faz cada linha já vir como dicionário
    (ex.: {"plano_id": 1, "nome": "Prata"}), em vez de uma tupla."""
    return psycopg2.connect(cursor_factory=psycopg2.extras.RealDictCursor, **DB_CONFIG)


def init_db():
    """Executa ddl_tabelas.sql (e dml/seed, se existirem) num banco vazio.
    Chamado pelo comando `flask --app backend.app init-db`."""
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = True  # os próprios scripts .sql já têm BEGIN/COMMIT
    cur = conn.cursor()

    for nome in ["ddl_tabelas.sql", "dml_tabelas.sql", "seed.sql"]:
        arquivo = DB_DIR / nome
        if arquivo.exists():
            print("Executando:", nome)
            cur.execute(arquivo.read_text(encoding="utf-8"))
        else:
            print("(pulado, não existe)", nome)

    cur.close()
    conn.close()
    print("Banco pronto.")