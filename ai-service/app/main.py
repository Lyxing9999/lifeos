import logging
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from app.models import AiSummaryRequest, AiSummaryResult
from app.services.ai_service import AiSummaryService

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

logger = logging.getLogger(__name__)

app = FastAPI(
    title="LifeOS AI Summary Service",
    version="0.1.0",
    description="FastAPI microservice for LifeOS daily summaries",
)

ai_service = AiSummaryService()


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    body = await request.body()
    logger.warning("validation_error path=%s errors=%s body=%s", request.url.path, exc.errors(), body.decode("utf-8"))
    return JSONResponse(
        status_code=422,
        content={
            "detail": exc.errors(),
            "rawBody": body.decode("utf-8")
        },
    )


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/v1/summary/daily", response_model=AiSummaryResult)
def generate_daily_summary(request: AiSummaryRequest) -> AiSummaryResult:
    logger.info("ai_summary_request=%s", request.model_dump())
    return ai_service.generate(request)