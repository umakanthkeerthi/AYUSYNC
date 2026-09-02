import os
import sys

sys.path.insert(0, os.path.abspath("backend"))

from backend.app.core.database_session import engine
from backend.app.models.database import Base
from backend.app.models.database import *

def reset_db():
    if os.path.exists("backend/ayusync.db"):
        os.remove("backend/ayusync.db")
        print("Deleted old ayusync.db")
        
    print("Recreating schema...")
    Base.metadata.create_all(bind=engine)
    print("Schema created.")

if __name__ == "__main__":
    reset_db()
