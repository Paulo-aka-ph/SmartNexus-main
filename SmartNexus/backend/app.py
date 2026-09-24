import sqlite3
from datetime import date
from pathlib import Path

from flask import Flask, jsonify, redirect, request

# Raiz do projeto (a pasta acima de backend/)
BASE_DIR = Path(__file__).resolve().parent.parent
DB_DIR = BASE_DIR / "database"
DB_PATH = DB_DIR / "smartnexus.db"

# Serve a pasta frontend/ na raiz do site:
#   /paginas/planos.html  ->  frontend/paginas/planos.html
#   /estilo/base.css      ->  frontend/estilo/base.css
app = Flask(
    __name__,
    static_folder=str(BASE_DIR / "frontend"),
    static_url_path="",
)


# ---------- Banco de dados ----------
def get_db():
    db = sqlite3.connect(DB_PATH)
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA foreign_keys = ON")
    return db


@app.cli.command("init-db")
def init_db():
    """Recria o banco do zero: DDL -> DML -> seed.
    Uso: flask --app backend/app.py init-db"""
    if DB_PATH.exists():
        DB_PATH.unlink()
    db = sqlite3.connect(DB_PATH)
    for nome in ["ddl_tabelas.sql", "dml_tabelas.sql", "seed.sql"]:
        arquivo = DB_DIR / nome
        if arquivo.exists():
            db.executescript(arquivo.read_text(encoding="utf-8"))
            print("Executado:", nome)
    db.commit()
    db.close()
    print("Banco criado em", DB_PATH)


# ---------- Páginas ----------
@app.route("/")
def raiz():
    return redirect("/paginas/index.html")


# ---------- API: planos ----------
@app.route("/api/planos")
def api_planos():
    """Lista os planos ativos (para o front usar depois via fetch)."""
    try:
        db = get_db()
        linhas = db.execute(
            "SELECT plano_id, nome, descricao, qtd_anuncios_max, preco_base "
            "FROM plano WHERE ativo = 1 ORDER BY preco_base"
        ).fetchall()
        db.close()
    except sqlite3.Error as erro:
        return jsonify({"erro": f"Erro no banco: {erro}"}), 500
    return jsonify([dict(linha) for linha in linhas])


# ---------- Cadastro de cliente ----------
@app.route("/cadastro", methods=["POST"])
def cadastro():
    razao_social = request.form.get("razao_social", "").strip()
    cnpj = request.form.get("cnpj", "").strip()
    email = request.form.get("email", "").strip().lower()
    telefone = request.form.get("telefone", "").strip()

    if not all([razao_social, cnpj, email, telefone]):
        return "Preencha todos os campos.", 400

    db = get_db()
    try:
        db.execute(
            "INSERT INTO usuario (razao_social, cnpj, email, telefone, data_cadastro) "
            "VALUES (?, ?, ?, ?, ?)",
            (razao_social, cnpj, email, telefone, date.today().isoformat()),
        )
        db.commit()
    except sqlite3.IntegrityError:
        return "CNPJ ou e-mail já cadastrado.", 400
    except sqlite3.Error as erro:
        return f"Erro no banco: {erro}", 500
    finally:
        db.close()

    return redirect("/paginas/planos.html")


if __name__ == "__main__":
    app.run(debug=True)