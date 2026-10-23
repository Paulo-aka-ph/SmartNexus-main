"""
backend/routes/planos.py
Rota HTTP para o catálogo de planos.

  GET /api/planos -> lista os planos ativos
"""
import psycopg2
from flask import Blueprint, jsonify

from backend.models import planos as model

bp = Blueprint("planos", __name__, url_prefix="/api/planos")


@bp.route("", methods=["GET"])
def listar():
    try:
        return jsonify(model.listar_planos())
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500