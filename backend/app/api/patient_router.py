from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from app.core.database_session import get_db
from app.models.database import User, Patient, Condition, Medication, VitalSign

router = APIRouter(prefix="/api/v1/patients", tags=["patients"])

@router.get("/")
def get_all_patients(db: Session = Depends(get_db)):
    """Fetch all patients for dev/testing purposes"""
    patients = db.query(Patient).all()
    results = []
    for p in patients:
        results.append({
            "id": p.id,
            "name": p.user.full_name,
            "dob": p.date_of_birth
        })
    return results

@router.get("/{patient_id}/profile")
def get_patient_profile(patient_id: str, db: Session = Depends(get_db)):
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    return {
        "id": patient.id,
        "name": patient.user.full_name,
        "phone": patient.user.phone_number,
        "dob": patient.date_of_birth,
        "blood_type": patient.blood_type
    }

@router.get("/{patient_id}/conditions")
def get_patient_conditions(patient_id: str, db: Session = Depends(get_db)):
    conditions = db.query(Condition).filter(Condition.patient_id == patient_id).all()
    return [{
        "id": c.id,
        "name": c.condition_name,
        "status": c.status
    } for c in conditions]

@router.get("/{patient_id}/medications")
def get_patient_medications(patient_id: str, db: Session = Depends(get_db)):
    medications = db.query(Medication).filter(Medication.patient_id == patient_id).all()
    return [{
        "id": m.id,
        "name": m.drug_name,
        "dosage": m.dosage,
        "frequency": m.frequency,
        "is_active": m.is_active
    } for m in medications]

@router.get("/{patient_id}/vitals")
def get_patient_vitals(patient_id: str, db: Session = Depends(get_db)):
    # Get the latest vitals, ordered by timestamp descending
    vitals = db.query(VitalSign).filter(VitalSign.patient_id == patient_id)\
               .order_by(VitalSign.timestamp.desc()).limit(10).all()
    return [{
        "id": v.id,
        "timestamp": v.timestamp,
        "heart_rate": v.heart_rate,
        "bp_systolic": v.blood_pressure_systolic,
        "bp_diastolic": v.blood_pressure_diastolic,
        "spo2": v.oxygen_saturation
    } for v in vitals]

@router.post("/simulate-discharge/{ehr_patient_id}")
def simulate_discharge(ehr_patient_id: str, db: Session = Depends(get_db)):
    """Simulate webhook from EHR and generate AyuSync login credentials."""
    # Generate mock credentials for the simulation pitch
    short_id = ehr_patient_id[:4].upper() if len(ehr_patient_id) > 4 else "8472"
    return {
        "status": "success",
        "username": f"AYU-{short_id}-X",
        "password": "temp_password_123"
    }
