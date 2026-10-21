"""
backend/app.py
Ponto de entrada do servidor Flask do Smart Nexus.

Este arquivo só monta a aplicação: serve o frontend e registra as rotas.
Cada parte tem um lugar só:
    db.py       -> conexão com o PostgreSQL (e o comando init-db)
    schemas.py  -> validação dos dados recebidos
    models/     -> SQL de cada tabela
    routes/     -> endpoints HTTP (/api/...)

Como preparar o banco (uma vez só):
    1. Crie um banco vazio chamado "smartnexus" no seu PostgreSQL:
           createdb smartnexus
    2. Ajuste DB_CONFIG em backend/db.py com o usuário/senha do seu Postgres.
    3. Na pasta do projeto, rode:
           flask --app backend/app.py init-db

Como rodar o site (abra SEMPRE pelo servidor, não clicando no .html):
    flask --app backend/app.py run --debug
    Depois abra http://127.0.0.1:5000
"""
from flask import Flask, redirect

from backend.db import BASE_DIR, init_db
from backend.routes import demandas, planos, usuarios

app = Flask(
    __name__,
    static_folder=str(BASE_DIR / "frontend"),
    static_url_path="",
)

app.register_blueprint(planos.bp)
app.register_blueprint(demandas.bp)
app.register_blueprint(usuarios.bp)


@app.cli.command("init-db")
def init_db_command():
    """Cria as tabelas e popula o banco. Uso: flask --app backend/app.py init-db"""
    init_db()


@app.route("/")
def raiz():
    return redirect("/paginas/index.html")


if __name__ == "__main__":
    app.run(debug=True)
