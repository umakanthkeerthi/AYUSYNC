from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import Practitioner, Patient, Medication, User, UserRole, DoctorEscalation

router = APIRouter(prefix="/api/v1/doctor", tags=["doctor"])

class LoginPayload(BaseModel):
    username: str
    password: str

@router.post("/login")
def login_doctor(payload: LoginPayload, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == payload.username, User.role == UserRole.DOCTOR).first()
    
    if not user or user.hashed_password != payload.password:
        raise HTTPException(status_code=401, detail="Invalid username or password")
        
    practitioner_profile = db.query(Practitioner).filter(Practitioner.user_id == user.id).first()
    if not practitioner_profile:
        raise HTTPException(status_code=404, detail="Doctor profile not found")
        
    return {
        "status": "success",
        "doctor_id": user.id,
        "name": user.full_name
    }

@router.get("/roster")
def get_patient_roster(doctor_id: str, db: Session = Depends(get_db)):
    # Find practitioner profile
    practitioner = db.query(Practitioner).filter(Practitioner.user_id == doctor_id).first()
    
    if not practitioner:
        return {"status": "success", "roster": []}

    # Find patients assigned to this doctor via medications
    meds = db.query(Medication).filter(Medication.prescribed_by_id == practitioner.id).all()
    patient_ids = list(set([m.patient_id for m in meds]))
    patients = db.query(Patient).filter(Patient.id.in_(patient_ids)).all()
    
    roster = []
    for p in patients:
        # Get actual risk score from DoctorEscalation table
        escalation = db.query(DoctorEscalation).filter(
            DoctorEscalation.patient_id == p.id
        ).order_by(DoctorEscalation.timestamp.desc()).first()
        
        score = escalation.risk_score if escalation else 0
        
        if score > 70:
            status = "Need Intervention"
            isHighRisk = True
        elif score > 40:
            status = "Monitoring"
            isHighRisk = False
        else:
            status = "Stable"
            isHighRisk = False

        # Calculate age from DOB
        age = "Unknown"
        if p.date_of_birth:
            from datetime import datetime, timezone
            now = datetime.now(timezone.utc)
            dob = p.date_of_birth
            if dob.tzinfo is None:
                dob = dob.replace(tzinfo=timezone.utc)
            delta = now - dob
            age = str(delta.days // 365)
            
        roster.append({
            "patient_id": p.id,
            "name": p.user.full_name if p.user else "Unknown Patient",
            "age": age,
            "status": status,
            "risk_score": score,
            "isHighRisk": isHighRisk
        })

    return {"status": "success", "roster": roster}

class NotePayload(BaseModel):
    content: str

@router.get("/patient/{patient_id}/review")
def get_patient_review(patient_id: str, db: Session = Depends(get_db)):
    from app.models.database import ClinicalNote
    
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    escalation = db.query(DoctorEscalation).filter(DoctorEscalation.patient_id == patient_id).order_by(DoctorEscalation.timestamp.desc()).first()
    notes = db.query(ClinicalNote).filter(ClinicalNote.patient_id == patient_id).order_by(ClinicalNote.timestamp.desc()).all()
    meds = db.query(Medication).filter(Medication.patient_id == patient_id, Medication.is_active == True).all()
    
    # Calculate age
    age = "Unknown"
    if patient.date_of_birth:
        from datetime import datetime, timezone
        now = datetime.now(timezone.utc)
        dob = patient.date_of_birth
        if dob.tzinfo is None:
            dob = dob.replace(tzinfo=timezone.utc)
        delta = now - dob
        age = str(delta.days // 365)
        
    return {
        "status": "success",
        "patient": {
            "name": patient.user.full_name if patient.user else "Unknown",
            "age": age,
            "blood_type": patient.blood_type or "Unknown",
        },
        "summary": escalation.shap_explanation if escalation else "No immediate risks identified.",
        "risk_score": escalation.risk_score if escalation else 0,
        "notes": [
            {
                "id": n.id,
                "text": n.content_text,
                "timestamp": n.timestamp.isoformat()
            } for n in notes
        ],
        "prescriptions": [
            {
                "id": m.id,
                "drug_name": m.drug_name,
                "dosage": m.dosage,
                "frequency": m.frequency
            } for m in meds
        ]
    }

@router.post("/patient/{patient_id}/note")
def add_clinical_note(patient_id: str, payload: NotePayload, db: Session = Depends(get_db)):
    from app.models.database import ClinicalNote
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    note = ClinicalNote(
        patient_id=patient_id,
        note_type="DOCTOR_NOTE",
        content_text=payload.content
    )
    db.add(note)
    db.commit()
    
    return {"status": "success", "message": "Note added successfully"}
