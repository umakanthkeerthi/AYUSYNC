import os
from dotenv import load_dotenv

# Force load the .env from the backend directory
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

from app.core.database_session import SessionLocal
from app.models.database import User, UserRole

def get_creds():
    db = SessionLocal()
    try:
        patients = db.query(User).filter(User.role == UserRole.PATIENT).all()
        
        print("\n=== PATIENT CREDENTIALS ===")
        if not patients:
            print("No patients found in the live database.")
            print("Please go to the Admin Portal (http://localhost:8000/admin), select a patient, and click 'Discharge Patient' to generate their credentials.")
        else:
            for p in patients:
                print(f"Name:     {p.full_name}")
                print(f"Username: {p.username}")
                print(f"Password: {p.hashed_password}")
                print("-" * 25)
    except Exception as e:
        print(f"Database Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    get_creds()
