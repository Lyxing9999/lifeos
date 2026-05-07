import json
import logging
from app.config import settings
from app.models import AiSummaryRequest, AiSummaryResult
from app.prompt_builder import SYSTEM_PROMPT, build_user_prompt
from app.services.fallback_service import generate_fallback
from app.clients.gemini_client import build_gemini_client

logger = logging.getLogger(__name__)


class AiSummaryService:
    def __init__(self) -> None:
        self._client = None
        if settings.gemini_api_key:
            self._client = build_gemini_client()

    def generate(self, req: AiSummaryRequest) -> AiSummaryResult:
        logger.info("gemini_enabled=%s model=%s", self._client is not None, settings.gemini_model)

        if self._client is None:
            logger.info("ai_summary_fallback_used reason=no_gemini_api_key")
            return generate_fallback(req)

        schema = {
            "type": "object",
            "properties": {
                "summaryText": {"type": "string"},
                "scoreExplanation": {"type": "string"},
                "insight": {"type": "string"},
            },
            "required": ["summaryText", "scoreExplanation", "insight"],
        }

        try:
            response = self._client.models.generate_content(
                model=settings.gemini_model,
                contents=build_user_prompt(req),
                config={
                    "system_instruction": SYSTEM_PROMPT,
                    "response_mime_type": "application/json",
                    "response_schema": schema,
                    "temperature": 0.4,
                },
            )

            raw = response.text
            data = json.loads(raw)

            logger.info("ai_summary_generated provider=gemini model=%s", settings.gemini_model)

            return AiSummaryResult(
                summaryText=data["summaryText"],
                scoreExplanation=data["scoreExplanation"],
                insight=data["insight"],
                fallbackUsed=False,
                model=settings.gemini_model,
            )
        except Exception as ex:
            logger.warning("ai_summary_failed_using_fallback provider=gemini error=%s", str(ex))
            return generate_fallback(req)