import os
import sys

# Add the root 'backend' dir to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.core.database_session import SessionLocal
from app.models.database import Patient, ClinicalNote

def seed():
    db = SessionLocal()
    
    patients = db.query(Patient).all()
    if not patients:
        print("No patients found in DB.")
        db.close()
        return
        
    print(f"Seeding clinical notes for {len(patients)} patients...")
    
    # Delete existing notes to prevent duplicates on rerun
    db.query(ClinicalNote).delete()
    db.commit()
    
    for p in patients:
        # Create a detailed initial history note
        history_note = ClinicalNote(
            patient_id=p.id,
            note_type="MEDICAL_HISTORY",
            content_text="Patient presents with a history of hypertension and Type 2 Diabetes. Has been experiencing intermittent shortness of breath over the last 2 weeks. Family history is significant for cardiovascular disease. Current BMI is 28. Advised lifestyle modifications including reduced sodium intake and daily 30-minute walks."
        )
        db.add(history_note)
        
        # Create a recent follow-up note
        followup_note = ClinicalNote(
            patient_id=p.id,
            note_type="FOLLOW_UP",
            content_text="Patient reports feeling slightly better but still experiences fatigue in the afternoons. Blood pressure today was 135/85. Will monitor closely and re-evaluate medication dosages if symptoms persist. Recommended continuation of current care plan."
        )
        db.add(followup_note)
        
    db.commit()
    db.close()
    print("Successfully seeded clinical notes!")

if __name__ == "__main__":
    seed()
