from fastapi import APIRouter, HTTPException, Response, status
from database import supabase
from models.usuario import usuarioEntrada, usuarioSaida

router = APIRouter(prefix="/usuario", tags=["Usuario"])


@router.post("", response_model=usuarioSaida,
             status_code=status.HTTP_201_CREATED)
def cadastrar_usuario(dados: usuarioEntrada):
    conteudo = dados.model_dump(mode="json")
    resposta = (
        supabase.table("usuario")
        .insert(conteudo)
        .execute()
    )

    if not resposta.data:
        raise HTTPException(
            status_code=502,
            detail="O Supabase não retornou o usuário cadastrado.",
        )
    return resposta.data[0]


@router.get("", response_model=list[usuarioSaida])
def listar_usuario():
    resposta = (
        supabase.table("usuario")
        .select("*")
        .order("id_usuario")
        .execute()
    )
    return resposta.data


@router.get("/{id_usuario}", response_model=usuarioSaida)
def consultar_usuario(id_usuario: int):
    resposta = (
        supabase.table("usuario")
        .select("*")
        .eq("id_usuario", id_usuario)
        .execute()
    )
    if not resposta.data:
        raise HTTPException(404, "Usuário não encontrado.")
    return resposta.data[0]


@router.put("/{id_usuario}", response_model=usuarioSaida)
def atualizar_usuario(id_usuario: int, dados: usuarioEntrada):
    conteudo = dados.model_dump(mode="json")
    resposta = (
        supabase.table("usuario")
        .update(conteudo)
        .eq("id_usuario", id_usuario)
        .execute()
    )
    if not resposta.data:
        raise HTTPException(404, "Usuário não encontrado.")
    return resposta.data[0]


@router.delete("/{id_usuario}", status_code=status.HTTP_204_NO_CONTENT)
def excluir_usuario(id_usuario: int):
    resposta = (
        supabase.table("usuario")
        .delete()
        .eq("id_usuario", id_usuario)
        .execute()
    )
    if not resposta.data:
        raise HTTPException(404, "Usuário não encontrado.")
    return Response(status_code=status.HTTP_204_NO_CONTENT)