import os
from dotenv import load_dotenv

# Force load the .env from the backend directory
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

from app.core.database_session import SessionLocal
from app.models.database import User, UserRole

def set_creds():
    db = SessionLocal()
    try:
        patient = db.query(User).filter(User.full_name == "Ramesh Gupta", User.role == UserRole.PATIENT).first()
        if patient:
            patient.username = "AYU-1234"
            patient.hashed_password = "temp_password_123"
            db.commit()
            print("Successfully updated Ramesh Gupta credentials.")
            print(f"Username: {patient.username}")
            print(f"Password: {patient.hashed_password}")
        else:
            print("Patient not found.")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    set_creds()
