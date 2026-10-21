"""
backend/schemas.py
Responsabilidade única: conferir se os dados recebidos em cada rota têm
o formato esperado, ANTES de chegarem nas funções de backend/models/.

Cada função de validação devolve uma lista de erros em português,
pronta para ser mostrada ao usuário. Lista vazia = dados válidos.
"""

# ---------------------------------------------------------------
# Cadastro de cliente (tabela usuario)
# ---------------------------------------------------------------
CAMPOS_OBRIGATORIOS_USUARIO = ["razao_social", "cnpj", "email", "telefone"]


def validar_usuario(dados):
    erros = []
    for campo in CAMPOS_OBRIGATORIOS_USUARIO:
        if not str(dados.get(campo, "")).strip():
            erros.append(f"O campo '{campo}' é obrigatório.")

    email = str(dados.get("email", "")).strip()
    if email and "@" not in email:
        erros.append("E-mail inválido.")

    return erros


# ---------------------------------------------------------------
# Pedido de orçamento (tabela demanda)
# ---------------------------------------------------------------

# Campos de texto simples (vêm direto do formulário de demandas.html)
CAMPOS_TEXTO_DEMANDA = [
    "nome_projeto", "empresa", "segmento", "responsavel", "cnpj",
    "email", "telefone", "plano", "tipo", "orcamento", "prazo",
    "descricao", "endereco_site", "objetivo", "material", "publico",
    "regiao", "perfil_instagram", "verba", "logo", "cores", "referencias",
]

# Campos que vêm como lista (checkboxes marcados) e são salvos como JSONB
CAMPOS_LISTA_DEMANDA = ["basicas", "adicionais", "plataformas", "estilo"]

CAMPOS_OBRIGATORIOS_DEMANDA = [
    "nome_projeto", "empresa", "responsavel",
    "email", "telefone", "descricao", "plano", "tipo",
]

PLANOS_VALIDOS = ("prata", "gold", "diamond", "indefinido")
TIPOS_VALIDOS = ("site", "marketing", "ambos")


def validar_demanda(dados):
    erros = []
    for campo in CAMPOS_OBRIGATORIOS_DEMANDA:
        if not str(dados.get(campo, "")).strip():
            erros.append(f"O campo '{campo}' é obrigatório.")

    if dados.get("plano") not in PLANOS_VALIDOS:
        erros.append(f"Plano inválido. Use um de: {', '.join(PLANOS_VALIDOS)}.")

    if dados.get("tipo") not in TIPOS_VALIDOS:
        erros.append(f"Tipo de projeto inválido. Use um de: {', '.join(TIPOS_VALIDOS)}.")

    return erros