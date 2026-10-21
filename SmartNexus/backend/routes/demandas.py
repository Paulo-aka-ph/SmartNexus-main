"""
backend/routes/demandas.py
Rotas HTTP para os pedidos de orçamento enviados em demandas.html.

  POST /api/demandas        -> cria um novo pedido
  GET  /api/demandas         -> lista todos os pedidos
  GET  /api/demandas/<id>    -> busca um pedido específico
"""
import psycopg2
from flask import Blueprint, jsonify, request

from backend.models import demandas as model
from backend.schemas import validar_demanda

bp = Blueprint("demandas", __name__, url_prefix="/api/demandas")


@bp.route("", methods=["POST"])
def criar():
    dados = request.get_json(silent=True)
    if dados is None:
        return jsonify({"erro": "Envie os dados em JSON."}), 400

    erros = validar_demanda(dados)
    if erros:
        return jsonify({"erro": "Dados inválidos.", "detalhes": erros}), 400

    try:
        novo_id = model.criar_demanda(dados)
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500

    return jsonify({"mensagem": "Pedido recebido com sucesso.", "demanda_id": novo_id}), 201


@bp.route("", methods=["GET"])
def listar():
    try:
        return jsonify(model.listar_demandas())
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500


@bp.route("/<int:demanda_id>", methods=["GET"])
def buscar(demanda_id):
    try:
        demanda = model.buscar_demanda_por_id(demanda_id)
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500

    if demanda is None:
        return jsonify({"erro": "Pedido não encontrado."}), 404
    return jsonify(demanda)