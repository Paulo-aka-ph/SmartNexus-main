"""
backend/models/demandas.py
Lê e escreve a tabela 'demanda' (pedidos de orçamento enviados
pela página demandas.html, antes de virarem contrato).
"""
import psycopg2.extras

from backend.db import get_db
from backend.schemas import CAMPOS_LISTA_DEMANDA, CAMPOS_TEXTO_DEMANDA


def criar_demanda(dados):
    """Insere um novo pedido de orçamento. Retorna o demanda_id criado."""
    colunas = CAMPOS_TEXTO_DEMANDA + CAMPOS_LISTA_DEMANDA
    valores = []
    for campo in CAMPOS_TEXTO_DEMANDA:
        valores.append(str(dados.get(campo, "")).strip() or None)
    for campo in CAMPOS_LISTA_DEMANDA:
        # psycopg2.extras.Json converte a lista Python para a coluna JSONB
        valores.append(psycopg2.extras.Json(dados.get(campo, [])))

    nomes = ", ".join(colunas)
    marcadores = ", ".join(["%s"] * len(colunas))

    conn = get_db()
    try:
        cur = conn.cursor()
        cur.execute(
            f"INSERT INTO demanda ({nomes}) VALUES ({marcadores}) RETURNING demanda_id",
            valores,
        )
        novo_id = cur.fetchone()["demanda_id"]
        conn.commit()
        return novo_id
    finally:
        conn.close()


def listar_demandas():
    """Retorna um resumo de todos os pedidos, do mais recente para o mais antigo."""
    conn = get_db()
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT demanda_id, nome_projeto, empresa, email, telefone, "
            "plano, tipo, status, data_criacao "
            "FROM demanda ORDER BY data_criacao DESC"
        )
        resultado = []
        for linha in cur.fetchall():
            item = dict(linha)
            item["data_criacao"] = item["data_criacao"].isoformat()
            resultado.append(item)
        return resultado
    finally:
        conn.close()


def buscar_demanda_por_id(demanda_id):
    """Retorna um pedido completo (todos os campos), ou None se não existir."""
    conn = get_db()
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM demanda WHERE demanda_id = %s", (demanda_id,))
        linha = cur.fetchone()
        if linha is None:
            return None
        item = dict(linha)
        item["data_criacao"] = item["data_criacao"].isoformat()
        return item
    finally:
        conn.close()