from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "AI Resume Analyzer"
    DEBUG: bool = True
    MAX_FILE_SIZE_MB: int = 5

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()