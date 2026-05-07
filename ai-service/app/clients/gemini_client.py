from google import genai

from app.config import settings

def build_gemini_client() -> genai.Client:

    if not settings.gemini_api_key:

        raise ValueError("GEMINI_API_KEY is not configured")

    return genai.Client(api_key=settings.gemini_api_key)