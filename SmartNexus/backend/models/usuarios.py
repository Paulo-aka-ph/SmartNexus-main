"""
backend/models/usuarios.py
Lê e escreve a tabela 'usuario' (clientes cadastrados).
Não sabe nada sobre HTTP: recebe e devolve apenas dados Python.
"""
from backend.db import get_db


def criar_usuario(dados):
    """Insere um novo cliente. Retorna o usuario_id criado.
    Pode levantar psycopg2.errors.UniqueViolation se o CNPJ ou
    o e-mail já existirem (ambos são UNIQUE no banco)."""
    conn = get_db()
    try:
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO usuario (razao_social, cnpj, email, telefone) "
            "VALUES (%s, %s, %s, %s) RETURNING usuario_id",
            (
                dados["razao_social"].strip(),
                dados["cnpj"].strip(),
                dados["email"].strip().lower(),
                dados["telefone"].strip(),
            ),
        )
        novo_id = cur.fetchone()["usuario_id"]
        conn.commit()
        return novo_id
    finally:
        conn.close()


def listar_usuarios():
    """Retorna todos os clientes, do mais recente para o mais antigo."""
    conn = get_db()
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT usuario_id, razao_social, cnpj, email, telefone, data_cadastro "
            "FROM usuario ORDER BY data_cadastro DESC"
        )
        resultado = []
        for linha in cur.fetchall():
            item = dict(linha)
            item["data_cadastro"] = item["data_cadastro"].isoformat()
            resultado.append(item)
        return resultado
    finally:
        conn.close()


def buscar_usuario_por_id(usuario_id):
    """Retorna um cliente específico, ou None se o id não existir."""
    conn = get_db()
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT usuario_id, razao_social, cnpj, email, telefone, data_cadastro "
            "FROM usuario WHERE usuario_id = %s",
            (usuario_id,),
        )
        linha = cur.fetchone()
        if linha is None:
            return None
        item = dict(linha)
        item["data_cadastro"] = item["data_cadastro"].isoformat()
        return item
    finally:
        conn.close()