import asyncio
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.database import User, Patient

from app.core.config import settings

def main():
    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()

    phone = "9951258552"
    user = session.query(User).filter(User.phone_number == phone).first()
    if user:
        print(f"Found user {user.username} with ID {user.id}. Deleting...")
        
        # Delete the patient profile first if it exists
        patient = session.query(Patient).filter(Patient.user_id == user.id).first()
        if patient:
            print(f"Found associated patient profile {patient.id}. Deleting...")
            session.delete(patient)
            
        session.delete(user)
        session.commit()
        print("Successfully deleted user and patient profile!")
    else:
        print("User not found!")

if __name__ == "__main__":
    main()
