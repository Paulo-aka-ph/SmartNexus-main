"""
backend/models/planos.py
Lê a tabela 'plano' (catálogo de pacotes vendidos pela Smart Nexus).
"""
from backend.db import get_db


def listar_planos():
    """Retorna os planos ativos, do mais barato para o mais caro."""
    conn = get_db()
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT plano_id, nome, descricao, qtd_anuncios_max, "
            "preco_base, periodicidade "
            "FROM plano WHERE ativo = TRUE ORDER BY preco_base"
        )
        return [dict(linha) for linha in cur.fetchall()]
    finally:
        conn.close()


def plano_existe(plano_id):
    """Confere se um plano_id existe no banco.
    Usado por quem precisar validar uma chave estrangeira para plano
    (ex.: ao criar um contrato) antes de tentar o INSERT."""
    conn = get_db()
    try:
        cur = conn.cursor()
        cur.execute("SELECT 1 FROM plano WHERE plano_id = %s", (plano_id,))
        return cur.fetchone() is not None
    finally:
        conn.close()