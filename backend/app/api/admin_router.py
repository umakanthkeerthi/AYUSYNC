import uuid
import requests
from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from datetime import datetime
from pydantic import BaseModel
from app.core.database_session import get_db
from app.models.database import (
    User, Patient, Practitioner, Encounter, Medication, 
    VitalSign, Condition, UserRole
)

router = APIRouter(prefix="/api/v1/admin", tags=["admin"])

EHR_API_BASE_URL = "http://13.60.9.54/api" # Using the live AWS mock EHR

class SetupPayload(BaseModel):
    ehr_patient_id: str
    doctor_username: str

def get_or_create_user(db: Session, name: str, role: UserRole, phone: str = None):
    user = db.query(User).filter(User.full_name == name, User.role == role).first()
    if not user:
        if not phone:
            phone = f"+1555{str(uuid.uuid4().int)[:6]}"
        user = User(
            id=str(uuid.uuid4()),
            full_name=name,
            role=role,
            phone_number=phone,
            username=f"AYU-{str(uuid.uuid4().int)[:4]}",
            hashed_password="mock_password"
        )
        db.add(user)
        db.flush()
    return user

@router.get("/ehr-patients")
def get_ehr_patients():
    try:
        res = requests.get(f"{EHR_API_BASE_URL}/patients/", timeout=5)
        res.raise_for_status()
        return res.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/setup-ecosystem")
def setup_ecosystem(payload: SetupPayload, db: Session = Depends(get_db)):
    try:
        # 1. Fetch Patient Demographics from EHR
        pat_res = requests.get(f"{EHR_API_BASE_URL}/patients/{payload.ehr_patient_id}", timeout=5)
        if pat_res.status_code != 200:
            raise HTTPException(status_code=400, detail="Patient not found in EHR")
        p_data = pat_res.json()
        
        # 2. Fetch Assigned Doctor
        doctor_user = db.query(User).filter(User.username == payload.doctor_username, User.role == UserRole.DOCTOR).first()
        if not doctor_user:
            raise HTTPException(status_code=400, detail="Assigned Doctor not found in the system.")
        doc_profile = db.query(Practitioner).filter(Practitioner.user_id == doctor_user.id).first()
            
        # 3. Create Patient User & Profile
        patient_user = db.query(User).filter(User.full_name == p_data.get('name', 'Unknown'), User.role == UserRole.PATIENT).first()
        if not patient_user:
            patient_user = User(
                id=str(uuid.uuid4()),
                full_name=p_data.get('name', 'Unknown'),
                role=UserRole.PATIENT,
                phone_number=f"+1555{str(uuid.uuid4().int)[:6]}",
                username=f"AYU-{str(uuid.uuid4().int)[:4]}",
                hashed_password="temp_password_123"
            )
            db.add(patient_user)
            db.flush()

        patient_profile = db.query(Patient).filter(Patient.user_id == patient_user.id).first()
        if not patient_profile:
            dob_str = p_data.get('dob', '1980-01-01')
            try:
                dob = datetime.strptime(dob_str, "%Y-%m-%d")
            except:
                dob = datetime(1980, 1, 1)
            patient_profile = Patient(
                id=str(uuid.uuid4()),
                user_id=patient_user.id,
                date_of_birth=dob
            )
            db.add(patient_profile)
            db.flush()
            
        # 5. Fetch and map clinical data
        # Encounters
        enc_res = requests.get(f"{EHR_API_BASE_URL}/patients/{payload.ehr_patient_id}/encounters", timeout=5)
        if enc_res.status_code == 200:
            for enc in enc_res.json():
                db.add(Encounter(id=str(uuid.uuid4()), patient_id=patient_profile.id, status=enc.get('status', 'finished')))
                
        # Medications
        med_res = requests.get(f"{EHR_API_BASE_URL}/patients/{payload.ehr_patient_id}/medications", timeout=5)
        if med_res.status_code == 200:
            for med in med_res.json():
                db.add(Medication(
                    id=str(uuid.uuid4()),
                    patient_id=patient_profile.id,
                    prescribed_by_id=doc_profile.id,
                    drug_name=med.get('name', 'Unknown Drug'),
                    dosage=med.get('dose', '1 pill'),
                    frequency=med.get('frequency', 'daily')
                ))
                
        # Conditions
        cond_res = requests.get(f"{EHR_API_BASE_URL}/patients/{payload.ehr_patient_id}/conditions", timeout=5)
        if cond_res.status_code == 200:
            for cond in cond_res.json():
                db.add(Condition(
                    id=str(uuid.uuid4()),
                    patient_id=patient_profile.id,
                    condition_name=cond.get('name', 'Unknown Condition'),
                    status=cond.get('status', 'active')
                ))
                
        # Vitals
        obs_res = requests.get(f"{EHR_API_BASE_URL}/patients/{payload.ehr_patient_id}/observations", timeout=5)
        if obs_res.status_code == 200:
            for obs in obs_res.json():
                name = obs.get('name', '').lower()
                val = obs.get('value', 0)
                if 'heart rate' in name:
                    db.add(VitalSign(id=str(uuid.uuid4()), patient_id=patient_profile.id, heart_rate=int(float(val))))
                elif 'blood pressure' in name:
                    try:
                        sys, dia = map(int, str(val).split('/'))
                        db.add(VitalSign(id=str(uuid.uuid4()), patient_id=patient_profile.id, blood_pressure_systolic=sys, blood_pressure_diastolic=dia))
                    except:
                        pass
        
        db.commit()
        return {
            "status": "success",
            "message": f"Successfully pulled EHR data and setup ecosystem for {patient_user.full_name}",
            "patient_user_id": patient_user.id,
            "patient_profile_id": patient_profile.id,
            "patient_username": patient_user.username,
            "patient_password": patient_user.hashed_password,
            "assigned_doctor": doctor_user.full_name
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
