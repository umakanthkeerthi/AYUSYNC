import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import User, Patient, UserRole, VitalSign, AdherenceLog, DoctorEscalation, Appointment

router = APIRouter(prefix="/api/v1/caregivers", tags=["caregivers"])

class CaregiverRegistration(BaseModel):
    patient_id: str
    full_name: str
    phone_number: str
    password: str

@router.post("/register")
def register_caregiver(payload: CaregiverRegistration, db: Session = Depends(get_db)):
    try:
        patient = db.query(Patient).filter(Patient.id == payload.patient_id).first()
        if not patient:
            raise HTTPException(status_code=404, detail="Patient with this Unique ID not found.")

        existing_caregiver = db.query(User).filter(User.phone_number == payload.phone_number).first()
        
        if existing_caregiver:
            if existing_caregiver.role != UserRole.CAREGIVER:
                raise HTTPException(status_code=400, detail="This phone number is registered to a non-caregiver account.")
            if existing_caregiver.hashed_password != payload.password:
                raise HTTPException(status_code=401, detail="Incorrect password for existing caregiver account.")
            
            caregiver_user = existing_caregiver
        else:
            caregiver_user = User(
                id=str(uuid.uuid4()),
                full_name=payload.full_name,
                role=UserRole.CAREGIVER,
                phone_number=payload.phone_number,
                username=f"CG-{payload.full_name.split()[0].upper()}-{str(uuid.uuid4())[:4]}",
                hashed_password=payload.password
            )
            db.add(caregiver_user)
            db.flush()

        patient.caregiver_id = caregiver_user.id
        db.commit()

        return {
            "status": "success",
            "message": "Caregiver authenticated and linked successfully.",
            "caregiver_id": caregiver_user.id,
            "patient_id": patient.id
        }

    except HTTPException as he:
        db.rollback()
        raise he
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{caregiver_id}/dashboard")
def get_dashboard(caregiver_id: str, db: Session = Depends(get_db)):
    # 1. Find patient linked to caregiver
    patient = db.query(Patient).filter(Patient.caregiver_id == caregiver_id).first()
    if not patient:
        return {"status": "error", "message": "No patient linked to this caregiver."}
        
    user = db.query(User).filter(User.id == patient.user_id).first()
    
    # 2. Vitals Status
    vitals = db.query(VitalSign).filter(VitalSign.patient_id == patient.id).order_by(VitalSign.recorded_at.desc()).first()
    vitals_status = "Stable"
    vitals_color = "green"
    if vitals:
        # Simplistic logic: if high BP or HR
        if vitals.systolic_bp and vitals.systolic_bp > 140:
            vitals_status = "Critical (High BP)"
            vitals_color = "amber"
            
    # 3. Medication Adherence
    med_log = db.query(AdherenceLog).filter(AdherenceLog.patient_id == patient.id).order_by(AdherenceLog.timestamp.desc()).first()
    med_status = "Done"
    med_color = "green"
    if med_log and med_log.status.value != "TAKEN":
        med_status = med_log.status.value.capitalize()
        med_color = "amber"
        
    # 4. Alerts (Escalations)
    escalation = db.query(DoctorEscalation).filter(DoctorEscalation.patient_id == patient.id, DoctorEscalation.status == 'PENDING').first()
    alerts = []
    if escalation:
        alerts.append({
            "text": f"High risk alert (Score: {escalation.risk_score}). Doctor notified.",
            "type": "Escalation",
            "color": "amber"
        })
        
    if not alerts and med_status != "Done":
        alerts.append({
            "text": f"Patient missed medication. Please check in.",
            "type": "Reminder",
            "color": "amber"
        })

    # 5. Appointments
    appt = db.query(Appointment).filter(Appointment.patient_id == patient.id).order_by(Appointment.scheduled_time.asc()).first()
    checkup_time = appt.scheduled_time.strftime("%I:%M %p") if appt else "No appointments"
    
    return {
        "patient": {
            "id": patient.id,
            "name": user.full_name,
            "photo_url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80",
            "vitals_status": vitals_status,
            "vitals_color": vitals_color,
            "last_updated": "Just now"
        },
        "glance": [
            { "icon": "pill", "title": "Medication", "status": med_status, "color": med_color },
            { "icon": "calendar", "title": "Checkup", "status": checkup_time, "color": "primary" }
        ],
        "alerts": alerts,
        "timeline": [
            { "icon": "activity", "title": f"Vitals Recorded: {vitals.systolic_bp}/{vitals.diastolic_bp} mmHg", "time": "Recently", "color": vitals_color } if vitals else None,
            { "icon": "pill", "title": f"Medication {med_status}", "time": "Recently", "color": med_color } if med_log else None
        ]
    }
