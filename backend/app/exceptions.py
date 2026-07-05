from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse


class AppException(Exception):
    def __init__(self, status_code: int, detail: str, type: str = "app_error"):
        self.status_code = status_code
        self.detail = detail
        self.type = type


def register_exception_handlers(app: FastAPI):
    @app.exception_handler(AppException)
    async def app_exception_handler(request: Request, exc: AppException):
        return JSONResponse(
            status_code=exc.status_code,
            content={"type": exc.type, "detail": exc.detail, "status": exc.status_code},
        )
