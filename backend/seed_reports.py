import os
from datetime import datetime, timedelta
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, ClinicalNote

db = SessionLocal()

user = db.query(User).filter(User.username == "AYU-1955").first()
if user:
    patient = db.query(Patient).filter(Patient.user_id == user.id).first()
    if patient:
        # Clear existing
        db.query(ClinicalNote).filter(ClinicalNote.patient_id == patient.id).delete()
        
        now = datetime.now()
        
        note1 = ClinicalNote(
            patient_id=patient.id,
            note_type="DISCHARGE_SUMMARY",
            content_text="Patient discharged after successful migraine management protocol.",
            timestamp=now - timedelta(days=5)
        )
        
        note2 = ClinicalNote(
            patient_id=patient.id,
            note_type="DISCHARGE_SUMMARY",
            content_text="Previous admission for gestational diabetes monitoring.",
            timestamp=now - timedelta(days=120)
        )
        
        note3 = ClinicalNote(
            patient_id=patient.id,
            note_type="RADIOLOGY",
            content_text="Head CT: No acute intracranial abnormality.",
            timestamp=now - timedelta(days=6)
        )
        
        db.add(note1)
        db.add(note2)
        db.add(note3)
        db.commit()
        print("Successfully seeded ClinicalNotes for Swathi (AYU-1955).")
    else:
        print("Patient profile not found.")
else:
    print("User AYU-1955 not found.")

db.close()
