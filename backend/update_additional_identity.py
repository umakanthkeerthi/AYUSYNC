import sys
import os
import uuid
from app.core.database_session import SessionLocal
from app.models.database import User, UserRole

def add_additional():
    db = SessionLocal()
    
    additions = [
        ("Driver Alex", "123456", UserRole.AMBULANCE_DRIVER, "AMB-ALEX"),
        ("Pharmacist Bob", "234567", UserRole.PHARMACIST, "PHA-BOB"),
        ("Tech Charlie", "345678", UserRole.LAB_TECH, "LAB-CHARLIE"),
        ("Agent Dana", "456789", UserRole.INSURANCE_REP, "INS-DANA"),
        ("Admin Eve", "567890", UserRole.ADMIN, "ADM-EVE")
    ]

    for name, phone, role, username in additions:
        # Check if we already have someone with this exact name and role
        user = db.query(User).filter(User.full_name == name, User.role == role).first()
        if user:
            print(f"{name} ({role.name}) already exists.")
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
            print(f"Created {name} as {role.name} with phone number {phone}")
            
    db.commit()
    print("Additional roles successfully added!")

if __name__ == "__main__":
    add_additional()
