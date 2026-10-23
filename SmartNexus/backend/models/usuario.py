from datetime import date 
from decimal import Decimal
from pydantic import BaseModel, Field, field_validator

class usuarioEntrada(BaseModel):
    razao_social_usuario: str= Field(min_length=1, max_length=150)
    cnpj_usuario: Decimal= Field(max_digits=14)
    email_usuario: str= Field(min_length=1, max_length=150)
    telefone_usuario: Decimal= Field(max_digits=11)
    data_cadastro_usuario: date




class usuarioSaida(usuarioEntrada):
    id_usuario: int