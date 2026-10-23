from datetime import date 
from decimal import Decimal
from pydantic import BaseModel, Field, field_validator

class servicoEntrada(BaseModel):
    nome_servico: str= Field(min_length=1, max_length=150)
    descricao_servico: str= Field(min_length=1, max_length=300)
    categoria_servico: str= Field(min_length=1, max_length=150)