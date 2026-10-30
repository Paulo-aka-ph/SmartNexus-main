import logging
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from postgrest.exceptions import APIError
from fastapi.middleware.cors import CORSMiddleware
from controller.usuario import router


logger = logging.getLogger("uvicorn.error")

app = FastAPI(
    title="SmartNexus - API de usuário",
    description="CRUD com Supabase por HTTPS"
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://127.0.0.1:5500", "http://localhost:5500"],
    allow_methods=["*"],
    allow_headers=["*"],
)
# Registra as rotas de usuário
app.include_router(router)


@app.exception_handler(APIError)
async def tratar_erro_supabase(request: Request, erro: APIError):
    logger.error("Erro na operação do Supabase: %s", erro)

    return JSONResponse(
        status_code=502,
        content={
            "detail": (
                "O Supabase recusou a operação. "
                "Confira a mensagem no terminal."
            )
        }
    )