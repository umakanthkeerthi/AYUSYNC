import sys
import os
import uuid
from app.core.database_session import SessionLocal
from app.models.database import User, UserRole

def update_identity():
    db = SessionLocal()
    
    updates = [
        ("Ananya Sharma", "+91 8328293177", UserRole.PATIENT, "PT-ANANYA"),
        ("Nurse Clara", "+91 8511565603", UserRole.NURSE, "NU-CLARA"),
        ("Giri", "+91 8247342805", UserRole.CAREGIVER, "CG-GIRI")
    ]

    for name, phone, role, username in updates:
        user = db.query(User).filter(User.full_name == name, User.role == role).first()
        if user:
            user.phone_number = phone
            user.username = username
            print(f"Updated {name}'s phone number to {phone}")
        else:
            u = User(
                id=str(uuid.uuid4()),
                full_name=name,
                role=role,
                phone_number=phone,
                username=username,
                hashed_password="password123"
            )
            db.add(u)
            print(f"Created {name} with phone number {phone}")
            
    # Update Doctors 
    doc1 = db.query(User).filter(User.full_name.ilike("%Gowrinath%"), User.role == UserRole.DOCTOR).first()
    if doc1:
        doc1.phone_number = "+91 8897579977"
        doc1.username = "DR-GOWRINATH"
        print(f"Updated {doc1.full_name}'s phone number to +91 8897579977")
    else:
        u = User(id=str(uuid.uuid4()), full_name="Dr. Gowrinath S.", role=UserRole.DOCTOR, phone_number="+91 8897579977", username="DR-GOWRINATH", hashed_password="password123")
        db.add(u)
        print("Created Dr. Gowrinath S.")
        
    doc2 = db.query(User).filter(User.full_name.ilike("%Uma%"), User.role == UserRole.DOCTOR).first()
    if doc2:
        doc2.phone_number = "+91 9182499217"
        doc2.username = "DR-UMA"
        print(f"Updated {doc2.full_name}'s phone number to +91 9182499217")
    else:
        u = User(id=str(uuid.uuid4()), full_name="Dr. Uma Kanth", role=UserRole.DOCTOR, phone_number="+91 9182499217", username="DR-UMA", hashed_password="password123")
        db.add(u)
        print("Created Dr. Uma Kanth")
        
    db.commit()
    print("Identity updates successfully committed!")

if __name__ == "__main__":
    update_identity()
