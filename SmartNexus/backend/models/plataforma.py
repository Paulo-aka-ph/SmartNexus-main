from datetime import date 
from decimal import Decimal
from pydantic import BaseModel, Field, field_validator

class plataformaEntrada(BaseModel):
    nome_plataforma: str= Field(min_length=1, max_length=150)
    tipo_platafroma: str= Field(min_length=1, max_length=150)

class plataformaSaida(plataformaEntrada):
    id_plataforma: int