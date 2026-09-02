import os
import sys

# Add the root 'backend' dir to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.core.database_session import SessionLocal
from app.models.database import User, Practitioner, Patient, Medication

def seed():
    db = SessionLocal()
    
    # 1. Get the target doctors
    gowrinath_user = db.query(User).filter(User.username == "gowrinath").first()
    umakanth_user = db.query(User).filter(User.username == "umakanth").first()
    
    if not gowrinath_user or not umakanth_user:
        print("Doctors not found. Make sure seed_identity.py was run.")
        db.close()
        return
        
    dr_gowrinath = db.query(Practitioner).filter(Practitioner.user_id == gowrinath_user.id).first()
    dr_umakanth = db.query(Practitioner).filter(Practitioner.user_id == umakanth_user.id).first()
    
    # If they don't have practitioner profiles, create them
    if not dr_gowrinath:
        dr_gowrinath = Practitioner(user_id=gowrinath_user.id, specialty="Cardiology")
        db.add(dr_gowrinath)
    if not dr_umakanth:
        dr_umakanth = Practitioner(user_id=umakanth_user.id, specialty="Neurology")
        db.add(dr_umakanth)
        
    db.commit()
    
    # 2. Get some patients
    patients = db.query(Patient).limit(5).all()
    if not patients:
        print("No patients found in DB.")
        db.close()
        return
        
    # 3. Create medications to link patients to doctors
    print("Linking patients to doctors...")
    
    # Clear existing dummy links if any
    db.query(Medication).filter(Medication.prescribed_by_id.in_([dr_gowrinath.id, dr_umakanth.id])).delete()
    db.commit()
    
    # Assign first 3 to Gowrinath
    for p in patients[:3]:
        med = Medication(
            patient_id=p.id,
            prescribed_by_id=dr_gowrinath.id,
            drug_name="Lisinopril",
            dosage="10mg",
            frequency="Once daily"
        )
        db.add(med)
        
    # Assign remaining to Umakanth
    for p in patients[3:]:
        med = Medication(
            patient_id=p.id,
            prescribed_by_id=dr_umakanth.id,
            drug_name="Metformin",
            dosage="500mg",
            frequency="Twice daily"
        )
        db.add(med)
        
    db.commit()
    db.close()
    
    print("Successfully mapped patients to Dr. Gowrinath and Dr. Umakanth!")

if __name__ == "__main__":
    seed()
