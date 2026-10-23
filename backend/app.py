
"""
backend/app.py
Servidor Flask do Smart Nexus.
 
Tudo num arquivo só: conexão com o banco, páginas e rotas da API
(planos, demandas e cadastro). Usa PostgreSQL (psycopg2).
 
Como preparar o banco (uma vez só):
    1. Crie um banco vazio chamado "smartnexus" no seu PostgreSQL.
       No terminal:  createdb smartnexus
       (ou pelo pgAdmin / DBeaver, criando um banco com esse nome)
    2. Ajuste DB_CONFIG logo abaixo com o usuário/senha do seu Postgres.
    3. Rode:  flask --app backend/app.py init-db
       Isso executa o ddl_tabelas.sql (e o dml/seed, se existirem).
 
Como rodar o site:
    flask --app backend/app.py run --debug
    Depois abra http://127.0.0.1:5000
"""
 
import json
from pathlib import Path
 
import psycopg2
import psycopg2.extras
from flask import Flask, jsonify, redirect, request
 
# ---------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------
 
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
 
app = Flask(
    __name__,
    static_folder=str(BASE_DIR / "frontend"),
    static_url_path="",
)
 
 
# ---------------------------------------------------------------
# Banco de dados
# ---------------------------------------------------------------
def get_db():
    """Abre uma conexão nova com o PostgreSQL.
    cursor_factory=RealDictCursor faz cada linha já vir como dicionário,
    igual ao sqlite3.Row, então dá para usar dict(linha) direto."""
    return psycopg2.connect(cursor_factory=psycopg2.extras.RealDictCursor, **DB_CONFIG)
 
 
@app.cli.command("init-db")
def init_db():
    """Executa o ddl_tabelas.sql (e dml/seed, se existirem) no banco vazio.
    Uso: flask --app backend/app.py init-db"""
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = True  # os próprios scripts já têm BEGIN/COMMIT
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
 
 
# ---------------------------------------------------------------
# Páginas
# ---------------------------------------------------------------
@app.route("/")
def raiz():
    return redirect("/paginas/index.html")
 
 
# ---------------------------------------------------------------
# API: planos
# ---------------------------------------------------------------
@app.route("/api/planos")
def api_planos():
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute(
            "SELECT plano_id, nome, descricao, qtd_anuncios_max, preco_base "
            "FROM plano WHERE ativo = TRUE ORDER BY preco_base"
        )
        linhas = cur.fetchall()
        cur.close()
        conn.close()
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500
    return jsonify([dict(linha) for linha in linhas])
 
 
# ---------------------------------------------------------------
# API: demandas
# ---------------------------------------------------------------
 
# Campos de texto simples (vêm direto do formulário)
CAMPOS_TEXTO = [
    "nome_projeto", "empresa", "segmento", "responsavel", "cnpj",
    "email", "telefone", "plano", "tipo", "orcamento", "prazo",
    "descricao", "endereco_site", "objetivo", "material", "publico",
    "regiao", "perfil_instagram", "verba", "logo", "cores", "referencias",
]
 
# Campos que vêm como lista (checkboxes marcados) e são salvos como JSONB
CAMPOS_LISTA = ["basicas", "adicionais", "plataformas", "estilo"]
 
# Campos que o servidor exige, porque sem eles a proposta não pode ser feita
CAMPOS_OBRIGATORIOS = [
    "nome_projeto", "empresa", "responsavel", "email",
    "telefone", "descricao", "plano", "tipo",
]
 
 
@app.route("/api/demandas", methods=["POST"])
def criar_demanda():
    dados = request.get_json(silent=True)
    if dados is None:
        return jsonify({"erro": "Envie os dados em JSON."}), 400
 
    faltando = [c for c in CAMPOS_OBRIGATORIOS if not str(dados.get(c, "")).strip()]
    if faltando:
        return jsonify({"erro": f"Campos obrigatórios faltando: {', '.join(faltando)}"}), 400
 
    if dados.get("plano") not in ("prata", "gold", "diamond", "indefinido"):
        return jsonify({"erro": "Plano inválido."}), 400
    if dados.get("tipo") not in ("site", "marketing", "ambos"):
        return jsonify({"erro": "Tipo de projeto inválido."}), 400
 
    colunas = CAMPOS_TEXTO + CAMPOS_LISTA
    valores = []
    for campo in CAMPOS_TEXTO:
        valores.append(str(dados.get(campo, "")).strip() or None)
    for campo in CAMPOS_LISTA:
        # psycopg2.extras.Json converte a lista Python para JSONB
        valores.append(psycopg2.extras.Json(dados.get(campo, [])))
 
    nomes = ", ".join(colunas)
    marcadores = ", ".join(["%s"] * len(colunas))
 
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute(
            f"INSERT INTO demanda ({nomes}) VALUES ({marcadores}) RETURNING demanda_id",
            valores,
        )
        novo_id = cur.fetchone()["demanda_id"]
        conn.commit()
        cur.close()
        conn.close()
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500
 
    return jsonify({"mensagem": "Pedido recebido com sucesso.", "demanda_id": novo_id}), 201
 
 
@app.route("/api/demandas", methods=["GET"])
def listar_demandas():
    """Lista os pedidos recebidos (para uma futura tela interna)."""
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute(
            "SELECT demanda_id, nome_projeto, empresa, email, telefone, "
            "plano, tipo, status, data_criacao "
            "FROM demanda ORDER BY data_criacao DESC"
        )
        linhas = cur.fetchall()
        cur.close()
        conn.close()
    except psycopg2.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500
 
    # data_criacao vem como datetime; convertido para texto para virar JSON
    resultado = []
    for linha in linhas:
        item = dict(linha)
        item["data_criacao"] = item["data_criacao"].isoformat()
        resultado.append(item)
    return jsonify(resultado)
 
 
# ---------------------------------------------------------------
# Cadastro de cliente
# ---------------------------------------------------------------
@app.route("/cadastro", methods=["POST"])
def cadastro():
    razao_social = request.form.get("razao_social", "").strip()
    cnpj = request.form.get("cnpj", "").strip()
    email = request.form.get("email", "").strip().lower()
    telefone = request.form.get("telefone", "").strip()
 
    if not all([razao_social, cnpj, email, telefone]):
        return "Preencha todos os campos.", 400
 
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO usuario (razao_social, cnpj, email, telefone) "
            "VALUES (%s, %s, %s, %s)",
            (razao_social, cnpj, email, telefone),
        )
        conn.commit()
        cur.close()
        conn.close()
    except psycopg2.errors.UniqueViolation:
        return "CNPJ ou e-mail já cadastrado.", 400
    except psycopg2.Error as erro:
        return f"Erro no banco: {erro}", 500
 
    return redirect("/paginas/planos.html")
 
 
if __name__ == "__main__":
    app.run(debug=True)
 