import sys
import os
import uuid
import requests
from app.core.database_session import SessionLocal
from app.models.database import User, UserRole

def seed_identity():
    db = SessionLocal()
    
    pat_res = requests.get("http://13.60.9.54/api/patients/")
    patients = pat_res.json()
    
    prac_res = requests.get("http://13.60.9.54/api/practitioners/")
    practitioners = prac_res.json()
    
    print(f"Fetched {len(patients)} patients and {len(practitioners)} practitioners")
    
    for p in practitioners:
        existing = db.query(User).filter(User.full_name == p['name'], User.role == UserRole.DOCTOR).first()
        if not existing:
            u = User(
                id=str(uuid.uuid4()),
                full_name=p['name'],
                role=UserRole.DOCTOR,
                phone_number=f"555-DOC-{p['id']}",
                username=f"DR-{p['name'].split()[-1].upper()}",
                hashed_password="password123"
            )
            db.add(u)
            print(f"Added Doctor: {p['name']}")

    for p in patients:
        existing = db.query(User).filter(User.full_name == p['name'], User.role == UserRole.PATIENT).first()
        if not existing:
            u = User(
                id=str(uuid.uuid4()),
                full_name=p['name'],
                role=UserRole.PATIENT,
                phone_number=p.get('contact_phone', f"555-PAT-{p['id']}"),
                username=f"PT-{p['name'].split()[0].upper()}",
                hashed_password="password123"
            )
            db.add(u)
            print(f"Added Patient: {p['name']}")
            
        cg_name = p.get('emergency_contact_name')
        if cg_name:
            cg_clean = cg_name.split('(')[0].strip()
            cg_phone = p.get('emergency_contact_phone', f"555-CG-{p['id']}")
            existing_cg = db.query(User).filter(User.full_name == cg_clean, User.role == UserRole.CAREGIVER).first()
            if not existing_cg:
                cg = User(
                    id=str(uuid.uuid4()),
                    full_name=cg_clean,
                    role=UserRole.CAREGIVER,
                    phone_number=cg_phone,
                    username=f"CG-{cg_clean.split()[0].upper()}",
                    hashed_password="password123"
                )
                db.add(cg)
                print(f"Added Caregiver: {cg_clean}")
                
    db.commit()
    print("Identity Tier successfully seeded!")

if __name__ == "__main__":
    seed_identity()
