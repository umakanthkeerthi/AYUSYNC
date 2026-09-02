import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.core.database_session import SessionLocal
from app.models.database import Practitioner, Patient, Medication, DoctorEscalation

def seed():
    db = SessionLocal()
    
    # 1. Get all medications to find patients assigned to doctors
    meds = db.query(Medication).all()
    patient_ids = list(set([m.patient_id for m in meds]))
    
    if not patient_ids:
        print("No patients assigned to doctors found.")
        db.close()
        return
        
    # Clear existing escalations for these patients to reset
    db.query(DoctorEscalation).filter(DoctorEscalation.patient_id.in_(patient_ids)).delete()
    db.commit()
    
    print(f"Assigning permanent risk scores to {len(patient_ids)} patients...")
    
    # Assign specific scores so UI looks good and consistent
    scores = [91, 55, 15, 20, 80, 45, 10]
    
    for i, p_id in enumerate(patient_ids):
        # find the doctor assigned to this patient
        med = db.query(Medication).filter(Medication.patient_id == p_id).first()
        score = scores[i % len(scores)]
        
        escalation = DoctorEscalation(
            patient_id=p_id,
            doctor_id=med.prescribed_by_id,
            risk_score=score,
            shap_explanation="Deterministic demo score seeded for consistency."
        )
        db.add(escalation)
        
    db.commit()
    db.close()
    
    print("Successfully seeded deterministic risk scores!")

if __name__ == "__main__":
    seed()
