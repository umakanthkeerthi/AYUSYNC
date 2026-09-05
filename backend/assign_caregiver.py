import os
import sys

sys.path.insert(0, os.path.abspath("."))

from app.core.database_session import SessionLocal
from app.models.database import User, Patient, UserRole

def assign_caregiver():
    db = SessionLocal()
    
    # 1. Create or get Caregiver User (Giri)
    caregiver = db.query(User).filter(User.username == "Giri123").first()
    if not caregiver:
        caregiver = User(
            full_name="Giri",
            username="Giri123",
            role=UserRole.CAREGIVER,
            phone_number="9951258552",
            hashed_password="12345678", # Plaintext for POC purposes, usually hashed
            email="giri@ayusync.com" # Dummy email as it might be required by schema
        )
        db.add(caregiver)
        db.commit()
        db.refresh(caregiver)
        print("Created new caregiver user: Giri")
    else:
        print("Caregiver Giri already exists.")
        
    # 2. Find Patient "rajeev udaiwal"
    patient_user = db.query(User).filter(User.full_name.ilike("%rajeev%")).first()
    if not patient_user:
        print("Patient 'rajeev' not found in users table!")
        return
        
    patient = db.query(Patient).filter(Patient.user_id == patient_user.id).first()
    if not patient:
        print(f"Patient profile for user {patient_user.full_name} not found!")
        return
        
    # 3. Assign caregiver to patient
    patient.caregiver_id = caregiver.id
    patient.caregiver_relation = "Family Member"
    db.commit()
    
    print(f"Successfully assigned Caregiver (Giri) to Patient ({patient_user.full_name})!")
    db.close()

if __name__ == "__main__":
    assign_caregiver()
