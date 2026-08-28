import os
from pydantic import BaseModel
from dotenv import load_dotenv

# Load environment variables from backend/.env file
load_dotenv()

class Settings(BaseModel):
    # Database Settings
    DATABASE_URL: str = os.getenv("DATABASE_URL", "")
    
    # AWS Settings
    AWS_ACCESS_KEY_ID: str = os.getenv("AWS_ACCESS_KEY_ID", "")
    AWS_SECRET_ACCESS_KEY: str = os.getenv("AWS_SECRET_ACCESS_KEY", "")
    AWS_REGION: str = os.getenv("AWS_REGION", "us-east-1")
    
    # EventBridge Settings
    AWS_EVENTBRIDGE_BUS_NAME: str = os.getenv("AWS_EVENTBRIDGE_BUS_NAME", "ayusync-event-bus")
    
    @property
    def has_aws_credentials(self) -> bool:
        return bool(self.AWS_ACCESS_KEY_ID and self.AWS_SECRET_ACCESS_KEY)

settings = Settings()
