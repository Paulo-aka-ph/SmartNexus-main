import os
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client, Client

# Carrega as variáveis do arquivo .env
caminho_env = Path(__file__).with_name(".env")
load_dotenv(caminho_env, override=True)

# Obtém as credenciais do Supabase
url = os.getenv("SUPABASE_URL")
chave = os.getenv("SUPABASE_KEY")

# Verifica se as credenciais existem
if not url or not chave:
    raise RuntimeError(
        "Configure SUPABASE_URL e SUPABASE_KEY no arquivo .env"
    )

# Cria a conexão com o Supabase
supabase: Client = create_client(url, chave)
