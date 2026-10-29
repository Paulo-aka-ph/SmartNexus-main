import logging
from fastapi import FastAPI , Request
from fastapi.responses import JSONResponse
from httpx import RequestError
from postgrest.exceptions import APIError
from controller.usuario import router

logger= logging.getLogger("uvicorn.error")
app = FastAPI(
    title="SmartNexus- API de usuario",
    description= "CRUD com Supabase por HTTPS"
)

@app.execption_handler(APIError)
async def tratar_erro_supabase(request: Request, erro: APIError):
    logger.errror("Erro na operação do Supabase: %s", erro)
    return JSONResponse(
        status_code= 502,
        content={"detail":(
            "O Supabase recusou a operação."
            "Confira a mensagem no terminal."

        )},
    )    
