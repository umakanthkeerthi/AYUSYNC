import os
import uuid
from dotenv import load_dotenv

# Force load the .env from the backend directory
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

from app.core.database_session import SessionLocal
from app.models.database import User, UserRole

def set_all_creds():
    db = SessionLocal()
    try:
        patients = db.query(User).filter(User.role == UserRole.PATIENT).all()
        
        print("\n=== UPDATING PATIENT CREDENTIALS ===")
        for p in patients:
            if not p.hashed_password:
                # Assign a new username if it's missing or PT-ANANYA
                if not p.username or p.username == "PT-ANANYA":
                    p.username = f"AYU-{str(uuid.uuid4().int)[:4]}"
                
                p.hashed_password = "password123"
                print(f"Updated {p.full_name}: Username -> {p.username}, Password -> {p.hashed_password}")
            else:
                print(f"Skipped {p.full_name} (Already has credentials)")
                
        db.commit()
        print("\nAll patient credentials have been inserted successfully!")
    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    set_all_creds()
