import sys
from app.core.database_session import SessionLocal
from app.models.database import User, UserRole

def update_credentials():
    db = SessionLocal()
    doctors = db.query(User).filter(User.role == UserRole.DOCTOR).all()
    
    print(f"Found {len(doctors)} doctors in the DB.")
    
    for doc in doctors:
        if "Gowrinath" in doc.full_name:
            doc.username = "gowrinath"
            doc.hashed_password = "password123"
            print(f"Updated {doc.full_name} -> username: gowrinath")
        elif "Uma Kanth" in doc.full_name:
            doc.username = "umakanth"
            doc.hashed_password = "password123"
            print(f"Updated {doc.full_name} -> username: umakanth")
            
    db.commit()
    print("Credentials updated successfully!")

if __name__ == "__main__":
    update_credentials()
