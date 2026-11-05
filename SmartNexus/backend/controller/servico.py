from fastapi import APIRouter, HTTPException, Response, status
from postgrest.exceptions import APIError
from database import supabase
from models.servico import servicoEntrada, servicoSaida

