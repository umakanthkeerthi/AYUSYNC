from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import Practitioner, Patient, Medication, User

router = APIRouter(prefix="/api/v1/doctor", tags=["doctor"])

@router.get("/roster")
def get_patient_roster(doctor_id: str, db: Session = Depends(get_db)):
    # Find practitioner profile
    practitioner = db.query(Practitioner).filter(Practitioner.user_id == doctor_id).first()
    if not practitioner:
        return {"status": "error", "message": "Doctor profile not found"}

    # Find patients assigned to this doctor via medications
    # In a real app, this might be via CarePlan or a direct association table
    meds = db.query(Medication).filter(Medication.prescribed_by_id == practitioner.id).all()
    patient_ids = list(set([m.patient_id for m in meds]))
    
    patients = db.query(Patient).filter(Patient.id.in_(patient_ids)).all()
    
    roster = []
    for p in patients:
        roster.append({
            "patient_id": p.id,
            "name": p.user.full_name if p.user else "Unknown",
            "dob": p.date_of_birth
        })

    return {"status": "success", "roster": roster}
