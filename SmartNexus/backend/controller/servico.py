from fastapi import APIRouter, HTTPException, Response, status
from postgrest.exceptions import APIError

from database import supabase
from models.servico import ServicoEntrada, ServicoSaida


# Cria o grupo de rotas dos serviços.
# Todas as rotas começarão com /servicos.
router = APIRouter(
    prefix="/servicos",
    tags=["Serviços"]
)



# 1. CREATE - CADASTRAR UM SERVIÇO


@router.post(
    "",
    response_model=ServicoSaida,
    status_code=status.HTTP_201_CREATED
)
def cadastrar_servico(dados: ServicoEntrada):

    # Transforma os dados recebidos em um dicionário.
    conteudo = dados.model_dump()

    try:
        # Envia os dados para a tabela servico no Supabase.
        resposta = (
            supabase.table("servico")
            .insert(conteudo)
            .execute()
        )

        # Verifica se o banco retornou o serviço cadastrado.
        if not resposta.data:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="O Supabase não retornou o serviço cadastrado."
            )

        return resposta.data[0]

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao cadastrar serviço no Supabase."
        ) from erro


# 2. READ - LISTAR TODOS OS SERVIÇOS


@router.get(
    "",
    response_model=list[ServicoSaida]
)
def listar_servicos():

    try:
        resposta = (
            supabase.table("servico")
            .select("*")
            .order("servico_id")
            .execute()
        )

        # Retorna todos os serviços encontrados.
        return resposta.data or []

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao consultar os serviços no Supabase."
        ) from erro


# 3. READ - CONSULTAR UM SERVIÇO PELO ID


@router.get(
    "/{servico_id}",
    response_model=ServicoSaida
)
def consultar_servico(servico_id: int):

    try:
        resposta = (
            supabase.table("servico")
            .select("*")
            .eq("servico_id", servico_id)
            .execute()
        )

        # Se não encontrar o serviço, retorna erro 404.
        if not resposta.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Serviço não encontrado."
            )

        return resposta.data[0]

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao consultar o serviço no Supabase."
        ) from erro


# ==================================================
# 4. UPDATE - ATUALIZAR UM SERVIÇO
@router.put(
    "/{servico_id}",
    response_model=ServicoSaida
)
def atualizar_servico(
    servico_id: int,
    dados: ServicoEntrada
):

    # Obtém os dados enviados pelo usuário.
    conteudo = dados.model_dump()

    try:
        resposta = (
            supabase.table("servico")
            .update(conteudo)
            .eq("servico_id", servico_id)
            .execute()
        )

        # Verifica se algum serviço foi atualizado.
        if not resposta.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Serviço não encontrado."
            )

        return resposta.data[0]

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao atualizar o serviço no Supabase."
        ) from erro


# ==================================================
# 5 DELETE - EXCLUIR UM SERVIÇO


@router.delete(
    "/{servico_id}",
    status_code=status.HTTP_204_NO_CONTENT
)
def excluir_servico(servico_id: int):

    try:
        resposta = (
            supabase.table("servico")
            .delete()
            .eq("servico_id", servico_id)
            .execute()
        )

        # Verifica se o serviço realmente existia.
        if not resposta.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Serviço não encontrado."
            )

        return Response(
            status_code=status.HTTP_204_NO_CONTENT
        )

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao excluir o serviço no Supabase."
        ) from erro


