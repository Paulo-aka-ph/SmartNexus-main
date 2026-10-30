from datetime import date 
from decimal import Decimal
from pydantic import BaseModel, Field, field_validator

class colaboradorEntrada(BaseModel):
    nome_colaborador: str= Field(min_length=1, max_length=150)
    email_colaborador: str= Field(min_length=1, max_length=150)
    cargo_colaborador: str= Field(min_length=1, max_length=150)

class colaboradorSaida(colaboradorEntrada):
    id_colaborador: int