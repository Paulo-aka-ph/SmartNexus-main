from fastapi import APIRouter, HTTPExeption, Responce, status 
from database import supabase 
from models.usuario import usuarioEntrada, usuarioSaida

router= APIRouter(prefix="/usuario", tags=["Usuario"])

@router.post("", response_model= usuarioSaida
            status_code= status.HTTP_201_CREATED)
def cadastrar_usuario(dados: usuarioEntrada): 
    conteudo = dados_model_dump(mode="json")
    resposta=(
        supabase.table("Usuario")
        .insert(conteudo)
        .execute()
        )