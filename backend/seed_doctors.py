import uuid
from sqlalchemy.orm import Session
from app.core.database_session import SessionLocal
from app.models.database import User, Practitioner, UserRole

def pre_seed_doctors():
    db = SessionLocal()
    
    doctors = [
        {"username": "dr_smith", "name": "Dr. Smith", "specialty": "Cardiology"},
        {"username": "dr_patel", "name": "Dr. Patel", "specialty": "Neurology"},
        {"username": "dr_chen", "name": "Dr. Chen", "specialty": "Internal Medicine"},
        {"username": "dr_carter", "name": "Dr. Emily Carter", "specialty": "General Practice"},
        {"username": "dr_jones", "name": "Dr. Jones", "specialty": "Oncology"},
    ]
    
    print("Pre-seeding 5 Demo Doctors into the database...")
    for doc in doctors:
        # Check if exists
        user = db.query(User).filter(User.username == doc["username"]).first()
        if not user:
            user = User(
                id=str(uuid.uuid4()),
                full_name=doc["name"],
                role=UserRole.DOCTOR,
                phone_number=f"+1555000{doctors.index(doc)}",
                username=doc["username"],
                hashed_password="password123" # Known credential
            )
            db.add(user)
            db.flush()
            
            # Create Practitioner profile
            practitioner = Practitioner(
                id=str(uuid.uuid4()),
                user_id=user.id,
                specialty=doc["specialty"]
            )
            db.add(practitioner)
            print(f"Created {doc['name']} ({doc['username']})")
        else:
            print(f"Skipped {doc['name']} - already exists.")
            
    db.commit()
    db.close()
    print("Done!")

if __name__ == "__main__":
    pre_seed_doctors()
