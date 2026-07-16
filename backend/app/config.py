# Configuration - loads .env variables, single source of truth
from pydantic_settings import BaseSettings #type: ignore

class Settings(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_KEY: str
    DATABASE_URL: str
    GEMINI_API_KEY: str = ""
    GOOGLE_PLACES_API_KEY: str = ""
    AT_API_KEY: str = ""
    AT_USERNAME: str = "sandbox"
    FRONTEND_URL: str = "https://vita.app"
    SUPABASE_JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440
    OPAY_MOCK: bool = True

    class Config:
        env_file = ".env"

settings = Settings()