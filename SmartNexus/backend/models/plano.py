from datetime import date
from decimal import Decimal
from pydantic import BaseModel, Field, field_validator

class PlanoEntrada(BaseModel):
    nome_plano: str = Field(min_length=1, max_length=150)
    data_plano: date
    valor_minimo: Decimal = Field(
        ge=0,
        max_digits=10,
        decimal_places=2,
    )

class PlanoSaida(PlanoEntrada):
    id_cliente: int
