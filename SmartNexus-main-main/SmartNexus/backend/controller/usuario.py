from fastapi import APIRouter, HTTPException, Response, status
from postgrest.exceptions import APIError
from database import supabase
from models.usuario import usuarioEntrada, usuarioSaida


router = APIRouter(
    prefix="/usuario",
    tags=["Usuario"]
)


# CADASTRAR USUÁRIO
import traceback   # no topo do arquivo, junto com os outros imports


@router.post("", response_model=usuarioSaida,
             status_code=status.HTTP_201_CREATED)
def cadastrar_usuario(dados: usuarioEntrada):
    conteudo = dados.model_dump(mode="json")
    print("ENVIANDO PARA O SUPABASE:", conteudo)

    try:
        resposta = (
            supabase.table("usuario")
            .insert(conteudo)
            .execute()
        )
    except Exception as erro:
        traceback.print_exc()
        raise HTTPException(
            status_code=502,
            detail=f"Erro ao cadastrar usuário no Supabase: {erro}",
        )

    if not resposta.data:
        raise HTTPException(
            status_code=502,
            detail="O Supabase não retornou o usuário cadastrado.",
        )
    return resposta.data[0]

# LISTAR TODOS OS USUÁRIOS
@router.get(
    "",
    response_model=list[usuarioSaida]
)
def listar_usuario():
    try:
        resposta = (
            supabase.table("usuario")
            .select("*")
            .order("id_usuario")
            .execute()
        )

        return resposta.data or []

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao consultar os usuários no Supabase."
        ) from erro


# CONSULTAR UM USUÁRIO PELO ID
@router.get(
    "/{id_usuario}",
    response_model=usuarioSaida
)
def consultar_usuario(id_usuario: int):
    try:
        resposta = (
            supabase.table("usuario")
            .select("*")
            .eq("id_usuario", id_usuario)
            .execute()
        )

        if not resposta.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Usuário não encontrado."
            )

        return resposta.data[0]

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao consultar usuário no Supabase."
        ) from erro


# ATUALIZAR USUÁRIO
@router.put(
    "/{id_usuario}",
    response_model=usuarioSaida
)
def atualizar_usuario(
    id_usuario: int,
    dados: usuarioEntrada
):
    try:
        conteudo = dados.model_dump(mode="json")

        resposta = (
            supabase.table("usuario")
            .update(conteudo)
            .eq("id_usuario", id_usuario)
            .execute()
        )

        if not resposta.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Usuário não encontrado."
            )

        return resposta.data[0]

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao atualizar usuário no Supabase."
        ) from erro


# EXCLUIR USUÁRIO
@router.delete(
    "/{id_usuario}",
    status_code=status.HTTP_204_NO_CONTENT
)
def excluir_usuario(id_usuario: int):
    try:
        resposta = (
            supabase.table("usuario")
            .delete()
            .eq("id_usuario", id_usuario)
            .execute()
        )

        if not resposta.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Usuário não encontrado."
            )

        return Response(
            status_code=status.HTTP_204_NO_CONTENT
        )

    except APIError as erro:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Erro ao excluir usuário no Supabase."
        ) from erro