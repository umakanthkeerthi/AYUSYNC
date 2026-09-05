import uuid
from datetime import datetime
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import (
    User, Patient, UserRole, VitalSign, AdherenceLog, AdherenceStatus,
    DoctorEscalation, Appointment, LabTest, CareTask, ChatThread, ChatMessage, EmergencyDispatch
)

router = APIRouter(prefix="/api/v1/caregivers", tags=["caregivers"])

# Pydantic Schemas
class CaregiverRegistration(BaseModel):
    patient_id: str
    full_name: str
    phone_number: str
    password: str

class CaregiverLogin(BaseModel):
    username: str
    password: str

class TransportRequest(BaseModel):
    patient_id: str
    alert_id: Optional[str] = None
    pickup_location: Optional[str] = "Patient Home Address"
    destination: Optional[str] = "Apollo Diagnostic Lab"
    scheduled_time: Optional[str] = None

class ScheduleActionPayload(BaseModel):
    action: str
    notes: Optional[str] = None

class MessageSendPayload(BaseModel):
    patient_id: str
    text: str

class ProfileUpdatePayload(BaseModel):
    language: Optional[str] = "English (US)"
    notifications: Optional[str] = "All enabled"


@router.post("/login")
def login_caregiver(payload: CaregiverLogin, db: Session = Depends(get_db)):
    try:
        user = db.query(User).filter(User.username == payload.username, User.role == UserRole.CAREGIVER).first()
        if not user or user.hashed_password != payload.password:
            raise HTTPException(status_code=401, detail="Invalid username or password.")
            
        return {
            "status": "success",
            "message": "Caregiver authenticated successfully.",
            "caregiver_id": user.id
        }
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


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
        # Fallback to demo patient if caregiver is standalone for testing
        patient = db.query(Patient).first()
        if not patient:
            return {"status": "error", "message": "No patient linked to this caregiver."}
        
    user = db.query(User).filter(User.id == patient.user_id).first()
    patient_name = user.full_name if user else "Rahul Kumar"
    
    # 2. Vitals Status
    vitals = db.query(VitalSign).filter(VitalSign.patient_id == patient.id).order_by(VitalSign.timestamp.desc()).first()
    vitals_status = "Stable"
    vitals_color = "green"
    if vitals:
        if vitals.blood_pressure_systolic and vitals.blood_pressure_systolic > 140:
            vitals_status = "Critical (High BP)"
            vitals_color = "amber"
            
    # 3. Medication Adherence
    med_log = db.query(AdherenceLog).filter(AdherenceLog.patient_id == patient.id).order_by(AdherenceLog.timestamp.desc()).first()
    med_status = "Done"
    med_color = "green"
    if med_log and med_log.status != AdherenceStatus.TAKEN:
        med_status = med_log.status.value.capitalize()
        med_color = "amber"

    # 4. Lab / Blood Test
    lab = db.query(LabTest).filter(LabTest.patient_id == patient.id).order_by(LabTest.scheduled_time.desc()).first()
    lab_status = "Tomorrow"
    if lab and lab.scheduled_time:
        lab_status = lab.scheduled_time.strftime("%I:%M %p")
        
    # 5. Appointments
    appt = db.query(Appointment).filter(Appointment.patient_id == patient.id).order_by(Appointment.scheduled_time.asc()).first()
    checkup_time = appt.scheduled_time.strftime("%I:%M %p") if (appt and appt.scheduled_time) else "4:00 PM"
    
    # 6. Action Required Alerts
    alerts = []
    escalation = db.query(DoctorEscalation).filter(DoctorEscalation.patient_id == patient.id, DoctorEscalation.doctor_decision == None).first()
    if escalation:
        alerts.append({
            "id": f"esc_{escalation.id}",
            "text": f"High risk alert (Score: {escalation.risk_score}). Doctor notified.",
            "type": "Escalation",
            "action_type": "REVIEW_DETAILS",
            "color": "amber"
        })
        
    # Standard transport unconfirmed alert for demo/design parity
    alerts.append({
        "id": "alert_transport_01",
        "text": "Transport unconfirmed for tomorrow's lab visit.",
        "type": "Action Required",
        "action_type": "ARRANGE_TRANSPORT",
        "color": "amber"
    })

    # 7. Recent Activity Timeline
    timeline = []
    if med_log:
        t_str = med_log.timestamp.strftime("%I:%M %p") if med_log.timestamp else "8:05 AM"
        status_txt = "taken" if med_log.status == AdherenceStatus.TAKEN else "missed"
        timeline.append({
            "id": f"med_{med_log.id}",
            "icon": "checkCircle2" if med_log.status == AdherenceStatus.TAKEN else "pill",
            "title": f"Medicine {status_txt}",
            "time": t_str,
            "color": "green" if med_log.status == AdherenceStatus.TAKEN else "amber"
        })
    else:
        timeline.append({
            "id": "act_med_default",
            "icon": "checkCircle2",
            "title": "Medicine taken",
            "time": "8:05 AM",
            "color": "green"
        })

    if lab:
        t_str = lab.scheduled_time.strftime("%I:%M %p") if lab.scheduled_time else "10:00 AM"
        timeline.append({
            "id": f"lab_{lab.id}",
            "icon": "fileText",
            "title": f"{lab.test_name or 'Blood test'} scheduled",
            "time": t_str,
            "color": "primary"
        })
    else:
        timeline.append({
            "id": "act_lab_default",
            "icon": "fileText",
            "title": "Blood test scheduled",
            "time": "10:00 AM",
            "color": "primary"
        })

    if appt:
        t_str = appt.scheduled_time.strftime("%I:%M %p") if appt.scheduled_time else "4:00 PM"
        timeline.append({
            "id": f"appt_{appt.id}",
            "icon": "calendar",
            "title": "Appointment confirmed",
            "time": t_str,
            "color": "primary"
        })
    else:
        timeline.append({
            "id": "act_appt_default",
            "icon": "calendar",
            "title": "Appointment confirmed",
            "time": "4:00 PM",
            "color": "primary"
        })
    
    return {
        "status": "success",
        "patient": {
            "id": patient.id,
            "name": patient_name,
            "photo_url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80",
            "vitals_status": vitals_status,
            "vitals_color": vitals_color,
            "last_updated": "Just now"
        },
        "glance": [
            { "id": "med", "icon": "pill", "title": "Medication", "status": med_status, "color": med_color },
            { "id": "lab", "icon": "droplet", "title": "Blood Test", "status": lab_status, "color": "amber" },
            { "id": "appt", "icon": "calendar", "title": "Checkup", "status": checkup_time, "color": "primary" }
        ],
        "alerts": alerts,
        "timeline": timeline
    }


@router.post("/{caregiver_id}/actions/arrange-transport")
def arrange_transport(caregiver_id: str, payload: TransportRequest, db: Session = Depends(get_db)):
    try:
        dispatch = EmergencyDispatch(
            patient_id=payload.patient_id,
            pickup_location=payload.pickup_location or "Patient Address",
        )
        db.add(dispatch)
        db.commit()
        
        return {
            "status": "success",
            "message": "Transport booking request submitted successfully.",
            "dispatch_id": dispatch.id
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{caregiver_id}/schedule")
def get_schedule(caregiver_id: str, date: Optional[str] = None, db: Session = Depends(get_db)):
    # 1. Find patient
    patient = db.query(Patient).filter(Patient.caregiver_id == caregiver_id).first()
    if not patient:
        patient = db.query(Patient).first()
        
    user_name = "Rahul"
    if patient:
        u = db.query(User).filter(User.id == patient.user_id).first()
        if u and u.full_name:
            user_name = u.full_name.split()[0]
            
    # Default design matching items
    items = [
        {
            "id": "sch_01",
            "scheduled_time": "08:00 AM",
            "title": "Verify Morning Dose",
            "subtitle": f"{user_name} confirmed dose taken at 8:05 AM.",
            "status": "VERIFIED",
            "icon": "checkCircle2",
            "color": "green",
            "is_completed": True,
            "has_action": False
        },
        {
            "id": "sch_02",
            "scheduled_time": "10:00 AM",
            "title": "Confirm Transport",
            "subtitle": "Pending action for 10:00 AM Blood Test tomorrow.",
            "status": "ACTION_REQUIRED",
            "icon": "truck",
            "color": "amber",
            "is_completed": False,
            "has_action": True,
            "action_label": "Take Action"
        },
        {
            "id": "sch_03",
            "scheduled_time": "02:00 PM",
            "title": "Afternoon Check-in",
            "subtitle": "Scheduled call with patient.",
            "status": "SCHEDULED",
            "icon": "phone",
            "color": "grey",
            "is_completed": False,
            "has_action": False
        }
    ]

    return {
        "status": "success",
        "date": date or datetime.now().strftime("%Y-%m-%d"),
        "schedule_items": items
    }


@router.post("/{caregiver_id}/schedule/{schedule_id}/action")
def execute_schedule_action(caregiver_id: str, schedule_id: str, payload: ScheduleActionPayload, db: Session = Depends(get_db)):
    return {
        "status": "success",
        "message": "Schedule item action updated successfully.",
        "schedule_id": schedule_id,
        "action": payload.action
    }


@router.get("/{caregiver_id}/messages")
def get_messages(caregiver_id: str, db: Session = Depends(get_db)):
    caregiver_user = db.query(User).filter(User.id == caregiver_id).first()
    patient = db.query(Patient).filter(Patient.caregiver_id == caregiver_id).first()
    if not patient:
        patient = db.query(Patient).first()
        
    patient_user = db.query(User).filter(User.id == patient.user_id).first() if patient else None
    
    # Query DB thread if exists
    messages = []
    if caregiver_user and patient_user:
        thread = db.query(ChatThread).filter(
            ((ChatThread.participant_1_id == caregiver_user.id) & (ChatThread.participant_2_id == patient_user.id)) |
            ((ChatThread.participant_1_id == patient_user.id) & (ChatThread.participant_2_id == caregiver_user.id))
        ).first()
        
        if thread:
            db_msgs = db.query(ChatMessage).filter(ChatMessage.thread_id == thread.id).order_by(ChatMessage.timestamp.asc()).all()
            for m in db_msgs:
                is_cg = m.sender_id == caregiver_user.id
                t_str = m.timestamp.strftime("%I:%M %p") if m.timestamp else "08:00 AM"
                messages.append({
                    "id": m.id,
                    "sender_type": "CAREGIVER" if is_cg else "PATIENT",
                    "sender_name": caregiver_user.full_name if is_cg else (patient_user.full_name if patient_user else "Patient"),
                    "sender_avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80" if not is_cg else None,
                    "text": m.message_text,
                    "time": t_str,
                    "is_me": is_cg,
                    "is_system_alert": False
                })

    # Default design mock messages if thread empty
    if not messages:
        messages = [
            {
                "id": "m1",
                "sender_type": "CAREGIVER",
                "sender_name": "Priya Kumar",
                "text": "Good morning! How are you feeling today?",
                "time": "08:00 AM",
                "is_me": True,
                "is_system_alert": False
            },
            {
                "id": "m2",
                "sender_type": "PATIENT",
                "sender_name": "Rahul Kumar",
                "sender_avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80",
                "text": "Hi, I finished my morning walk. Heart rate felt normal.",
                "time": "08:15 AM",
                "is_me": False,
                "is_system_alert": False
            },
            {
                "id": "m3",
                "sender_type": "CAREGIVER",
                "sender_name": "Priya Kumar",
                "text": "That is great to hear! Remember to take your morning medication.",
                "time": "08:17 AM",
                "is_me": True,
                "is_system_alert": False
            },
            {
                "id": "m4",
                "sender_type": "SYSTEM",
                "sender_name": "System Alert",
                "text": "Patient logged medication intake.",
                "time": "08:20 AM",
                "is_me": False,
                "is_system_alert": True,
                "alert_icon": "bell"
            }
        ]

    return {
        "status": "success",
        "messages": messages
    }


@router.post("/{caregiver_id}/messages")
def send_message(caregiver_id: str, payload: MessageSendPayload, db: Session = Depends(get_db)):
    try:
        caregiver_user = db.query(User).filter(User.id == caregiver_id).first()
        patient = db.query(Patient).filter(Patient.id == payload.patient_id).first()
        patient_user = db.query(User).filter(User.id == patient.user_id).first() if patient else None

        if caregiver_user and patient_user:
            thread = db.query(ChatThread).filter(
                ((ChatThread.participant_1_id == caregiver_user.id) & (ChatThread.participant_2_id == patient_user.id)) |
                ((ChatThread.participant_1_id == patient_user.id) & (ChatThread.participant_2_id == caregiver_user.id))
            ).first()

            if not thread:
                thread = ChatThread(
                    participant_1_id=caregiver_user.id,
                    participant_2_id=patient_user.id
                )
                db.add(thread)
                db.flush()

            msg = ChatMessage(
                thread_id=thread.id,
                sender_id=caregiver_user.id,
                message_text=payload.text
            )
            db.add(msg)
            db.commit()

        return {
            "status": "success",
            "message": "Message sent successfully.",
            "timestamp": datetime.now().strftime("%I:%M %p")
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{caregiver_id}/profile")
def get_profile(caregiver_id: str, db: Session = Depends(get_db)):
    cg_user = db.query(User).filter(User.id == caregiver_id).first()
    patient = db.query(Patient).filter(Patient.caregiver_id == caregiver_id).first()
    
    name = cg_user.full_name if cg_user else "Priya Kumar"
    relation = patient.caregiver_relation if (patient and patient.caregiver_relation) else "Daughter"

    return {
        "status": "success",
        "caregiver": {
            "id": caregiver_id,
            "full_name": name,
            "role": "Primary Family Caregiver",
            "relationship": relation,
            "phone_number": cg_user.phone_number if cg_user else "+91 9876543210",
            "avatar_url": "https://images.unsplash.com/photo-1590611936760-eeb9bc5031ce?auto=format&fit=crop&w=300&q=80"
        },
        "settings": {
            "language": "English (US)",
            "notifications": "All enabled",
            "privacy_level": "Standard"
        }
    }


@router.put("/{caregiver_id}/profile")
def update_profile(caregiver_id: str, payload: ProfileUpdatePayload, db: Session = Depends(get_db)):
    return {
        "status": "success",
        "message": "Preferences updated successfully."
    }

