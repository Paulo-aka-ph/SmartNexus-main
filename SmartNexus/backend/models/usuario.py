from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class usuarioEntrada(BaseModel):
    razao_social: str = Field(min_length=1, max_length=150)
    cnpj: Decimal = Field(max_digits=14)
    email: str = Field(min_length=1, max_length=150)
    telefone: Decimal = Field(max_digits=11)


class usuarioSaida(usuarioEntrada):
    usuario_id: int
    data_cadastro: datetime