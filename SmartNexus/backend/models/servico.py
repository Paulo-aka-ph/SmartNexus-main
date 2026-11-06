from datetime import date 
from decimal import Decimal
from pydantic import BaseModel, Field


# Dados que serão recebidos ao cadastrar ou atualizar um serviço
class ServicoEntrada(BaseModel):
    nome: str = Field(min_length=1, max_length=100)
    descricao: str | None = Field(default=None)
    categoria: str = Field(min_length=1, max_length=50)


# Dados que serão devolvidos pela API
class ServicoSaida(ServicoEntrada):
    servico_id: int
