"""
backend/routes/usuarios.py
Rotas HTTP para o cadastro de clientes.

  POST /api/usuarios        -> cria um cliente nov
  GET  /api/usuarios         -> lista todos os clientes
  GET  /api/usuarios/<id>    -> busca um cliente específico
"""
import psycopg2
from flask import Blueprint, jsonify, request

from backend.models import usuarios as model
from backend.schemas import validar_usuario

bp = Blueprint("usuarios", __name__, url_prefix="/api/usuarios")


@bp.route("", methods=["POST"])
def criar():
    dados = request.get_json(silent=True)
    if dados is None:
        return jsonify({"erro": "Envie os dados em JSON."}), 400

    erros = validar_usuario(dados)
    if erros:
        return jsonify({"erro": "Dados inválidos.", "detalhes": erros}), 400

    try:
        novo_id = model.criar_usuario(dados)
    except psycopg2.errors.UniqueViolation:
        return jsonify({"erro": "CNPJ ou e-mail já cadastrado."}), 409
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500

    return jsonify({"mensagem": "Cliente cadastrado com sucesso.", "usuario_id": novo_id}), 201


@bp.route("", methods=["GET"])
def listar():
    try:
        return jsonify(model.listar_usuarios())
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500


@bp.route("/<int:usuario_id>", methods=["GET"])
def buscar(usuario_id):
    try:
        usuario = model.buscar_usuario_por_id(usuario_id)
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500

    if usuario is None:
        return jsonify({"erro": "Cliente não encontrado."}), 404
    return jsonify(usuario)