import os

from dotenv import load_dotenv

load_dotenv()

class Settings:

    gemini_api_key: str = os.getenv("GEMINI_API_KEY", "")

    gemini_model: str = os.getenv("GEMINI_MODEL", "gemini-3-flash-preview")

    app_env: str = os.getenv("APP_ENV", "local")

    app_port: int = int(os.getenv("APP_PORT", "8010"))

settings = Settings()