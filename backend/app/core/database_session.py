from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from .config import settings

# If no DB URL is provided, we fall back to a local SQLite database for development testing
SQLALCHEMY_DATABASE_URL = settings.DATABASE_URL or "sqlite:///./ayusync_local.db"

# Create the SQLAlchemy Engine
if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
    )
else:
    # PostgreSQL configuration
    engine = create_engine(SQLALCHEMY_DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
