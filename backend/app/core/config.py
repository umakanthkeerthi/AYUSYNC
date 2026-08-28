import os
from pydantic import BaseModel
from dotenv import load_dotenv

# Load environment variables from backend/.env file
load_dotenv()

class Settings(BaseModel):
    # Database Settings
    _DATABASE_URL: str = os.getenv("DATABASE_URL", "")

    @property
    def DATABASE_URL(self) -> str:
        url = self._DATABASE_URL
        if url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+pg8000://", 1)
        if "?sslmode=" in url:
            url = url.split("?sslmode=")[0]
        return url
    
    # AWS Settings
    AWS_ACCESS_KEY_ID: str = os.getenv("AWS_ACCESS_KEY_ID", "")
    AWS_SECRET_ACCESS_KEY: str = os.getenv("AWS_SECRET_ACCESS_KEY", "")
    AWS_REGION: str = os.getenv("AWS_REGION", "us-east-1")
    
    # EventBridge Settings
    AWS_EVENTBRIDGE_BUS_NAME: str = os.getenv("AWS_EVENTBRIDGE_BUS_NAME", "ayusync-event-bus")
    
    # LLM (Groq) Configuration
    GROQ_API_KEY: str = os.getenv("GROQ_API_KEY", "dummy_key_if_not_set")
    GROQ_MODEL_NAME: str = os.getenv("GROQ_MODEL_NAME", "llama3-70b-8192")
    
    @property
    def has_aws_credentials(self) -> bool:
        return bool(self.AWS_ACCESS_KEY_ID and self.AWS_SECRET_ACCESS_KEY)

settings = Settings()
