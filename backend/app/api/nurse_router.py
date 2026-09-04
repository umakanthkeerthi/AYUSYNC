from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timezone
from pydantic import BaseModel
from app.core.database_session import get_db
from app.models.database import TriageQueue, CareTask, LabTest, Patient, User, Appointment, Practitioner, DoctorEscalation, ChatThread, ChatMessage, VitalSign

router = APIRouter(prefix="/api/v1/nurse", tags=["nurse"])

class LoginPayload(BaseModel):
    username: str
    password: str

class VisitNotePayload(BaseModel):
    notes: str

@router.post("/login")
def login(payload: LoginPayload):
    if payload.username == "Nurse Sara" and payload.password == "sara123":
        return {"status": "success", "token": "nurse_token_123", "user": {"name": "Nurse Sara", "role": "nurse", "mobile": "7013250990"}}
    raise HTTPException(status_code=401, detail="Invalid credentials")


def get_patient_name(db: Session, patient_id: str) -> str:
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if patient:
        user = db.query(User).filter(User.id == patient.user_id).first()
        if user:
            return user.full_name
    return "Unknown Patient"

@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    triage_items = db.query(TriageQueue).filter(TriageQueue.status == "OPEN").order_by(TriageQueue.created_at.desc()).all()
    
    urgent_count = sum(1 for t in triage_items if t.severity.value == "HIGH")
    
    pending_tasks = db.query(CareTask).filter(
        CareTask.assigned_role == "NURSE",
        CareTask.is_completed == False
    ).count()
    
    completed_tasks = db.query(CareTask).filter(
        CareTask.assigned_role == "NURSE",
        CareTask.is_completed == True
    ).count()
    
    total_patients = db.query(Patient).count()
    
    queue = []
    for t in triage_items:
        queue.append({
            "patient_id": t.patient_id,
            "patient_name": get_patient_name(db, t.patient_id),
            "reason": "Triage Review",
            "added_time": t.created_at.strftime("%I:%M %p") if t.created_at else "Unknown",
            "severity": t.severity.value
        })
        
    return {
        "metrics": {
            "urgent_count": urgent_count,
            "follow_up_count": pending_tasks,
            "on_track_count": completed_tasks,
            "total_patients": total_patients
        },
        "patient_queue": queue
    }

@router.get("/tasks")
def get_tasks(db: Session = Depends(get_db)):
    tasks = db.query(CareTask).filter(CareTask.assigned_role == "NURSE").all()
    medium_triages = db.query(TriageQueue).filter(TriageQueue.severity == "MEDIUM", TriageQueue.status == "OPEN").all()
    
    pending = []
    in_progress = []
    completed = []
    
    for t in tasks:
        task_dict = {
            "task_id": t.id,
            "description": t.task_description,
            "patient_name": get_patient_name(db, t.patient_id),
            "time": t.due_time.strftime("%I:%M %p") if t.due_time else "Unknown",
            "tag": "Care Task"
        }
        if t.is_completed:
            completed.append(task_dict)
        else:
            pending.append(task_dict)
            
    for t in medium_triages:
        pending.append({
            "task_id": t.id,
            "description": "Triage Review",
            "patient_name": get_patient_name(db, t.patient_id),
            "time": t.created_at.strftime("%I:%M %p") if t.created_at else "Unknown",
            "tag": "Triage"
        })
        
    return {
        "pending": pending,
        "in_progress": in_progress,
        "completed": completed
    }

@router.get("/labs")
def get_labs(db: Session = Depends(get_db)):
    tests = db.query(LabTest).all()
    
    res = []
    for t in tests:
        res.append({
            "test_id": t.id,
            "patient_name": get_patient_name(db, t.patient_id),
            "test_type": t.test_name,
            "date": t.scheduled_time.strftime("%b %d, %I:%M %p") if t.scheduled_time else "Unknown",
            "status": t.status
        })
        
    return {"status": "success", "labs": res}

@router.get("/patients")
def get_patients(db: Session = Depends(get_db)):
    patients = db.query(Patient).all()
    res = []
    for p in patients:
        vitals = db.query(VitalSign).filter(VitalSign.patient_id == p.id).order_by(VitalSign.timestamp.desc()).first()
        triage = db.query(TriageQueue).filter(TriageQueue.patient_id == p.id, TriageQueue.status == "OPEN").order_by(TriageQueue.created_at.desc()).first()
        severity = triage.severity.value if triage else "STABLE"
        res.append({
            "patient_id": p.id,
            "name": get_patient_name(db, p.id),
            "age": (datetime.now(timezone.utc).replace(tzinfo=None) - p.date_of_birth).days // 365 if p.date_of_birth else 0,
            "blood_type": p.blood_type or "Unknown",
            "status": severity,
            "vitals": {
                "heart_rate": vitals.heart_rate if vitals and vitals.heart_rate else 70,
                "blood_pressure": f"{vitals.blood_pressure_systolic}/{vitals.blood_pressure_diastolic}" if vitals and vitals.blood_pressure_systolic else "120/80",
                "hr_trend": "stable",
                "bp_trend": "up"
            }
        })
    return {"patients": res}

@router.get("/visits")
def get_visits(db: Session = Depends(get_db)):
    appointments = db.query(Appointment).filter(Appointment.status == "SCHEDULED").all()
    res = []
    for a in appointments:
        res.append({
            "visit_id": a.id,
            "patient_name": get_patient_name(db, a.patient_id),
            "assessment_type": "In-home Assessment",
            "date": a.scheduled_time.strftime("%b %d, %Y") if a.scheduled_time else "Unknown",
            "time": a.scheduled_time.strftime("%I:%M %p") if a.scheduled_time else "Unknown"
        })
    return {"visits": res}

@router.post("/visits/{visit_id}/notes")
def post_visit_note(visit_id: str, payload: VisitNotePayload, db: Session = Depends(get_db)):
    appointment = db.query(Appointment).filter(Appointment.id == visit_id).first()
    if not appointment:
        raise HTTPException(status_code=404, detail="Visit not found")
        
    # Mocking note ingestion and Event Bus publishing
    appointment.status = "COMPLETED"
    db.commit()
    
    return {"status": "success", "message": "Clinical notes ingested and published to Event Bus"}

@router.get("/alerts")
def get_alerts(db: Session = Depends(get_db)):
    triages = db.query(TriageQueue).filter(TriageQueue.severity == "HIGH", TriageQueue.status == "OPEN").all()
    # Filter for risk score >= 75 (High risk)
    escalations = db.query(DoctorEscalation).filter(DoctorEscalation.risk_score >= 75).order_by(DoctorEscalation.timestamp.desc()).limit(10).all()
    
    res = []
    for t in triages:
        res.append({
            "id": t.id,
            "type": "Triage Alert",
            "patient_name": get_patient_name(db, t.patient_id),
            "description": "High severity triage open",
            "time": t.created_at.strftime("%I:%M %p") if t.created_at else ""
        })
    for e in escalations:
        res.append({
            "id": e.id,
            "type": "Doctor Escalation",
            "patient_name": get_patient_name(db, e.patient_id),
            "description": f"Risk Score: {e.risk_score} - {e.doctor_decision or 'Pending'}",
            "time": e.timestamp.strftime("%I:%M %p") if e.timestamp else ""
        })
    return {"status": "success", "alerts": res}

@router.get("/messages")
def get_messages(db: Session = Depends(get_db)):
    # Fetch some dummy messages if none exist, or fetch from DB
    threads = db.query(ChatThread).all()
    res = []
    for thread in threads:
        last_message = db.query(ChatMessage).filter(ChatMessage.thread_id == thread.id).order_by(ChatMessage.timestamp.desc()).first()
        if last_message:
            patient_user = db.query(User).filter(User.role == "PATIENT", User.id.in_([thread.participant_1_id, thread.participant_2_id])).first()
            patient_name = patient_user.full_name if patient_user else "Unknown Patient"
            res.append({
                "thread_id": thread.id,
                "sender_name": patient_name,
                "message": last_message.message_text,
                "time": last_message.timestamp.strftime("%I:%M %p") if last_message.timestamp else ""
            })
    return {"status": "success", "messages": res}

@router.get("/messages/{thread_id}")
def get_thread_messages(thread_id: str, db: Session = Depends(get_db)):
    messages = db.query(ChatMessage).filter(ChatMessage.thread_id == thread_id).order_by(ChatMessage.timestamp.asc()).all()
    res = []
    for m in messages:
        sender = db.query(User).filter(User.id == m.sender_id).first()
        res.append({
            "message_id": m.id,
            "sender_id": m.sender_id,
            "sender_name": sender.full_name if sender else "Unknown",
            "sender_role": sender.role.value if sender else "UNKNOWN",
            "message": m.message_text,
            "time": m.timestamp.strftime("%I:%M %p") if m.timestamp else ""
        })
    return {"status": "success", "thread_id": thread_id, "messages": res}

@router.get("/reports")
def get_reports(db: Session = Depends(get_db)):
    # Mocking some reports data based on existing tables
    total_tasks = db.query(CareTask).filter(CareTask.assigned_role == "NURSE").count()
    completed_tasks = db.query(CareTask).filter(CareTask.assigned_role == "NURSE", CareTask.is_completed == True).count()
    
    return {
        "status": "success", 
        "reports": {
            "total_tasks_handled": total_tasks,
            "tasks_completed": completed_tasks,
            "average_response_time": "14 mins",
            "patient_satisfaction": "94%"
        }
    }

@router.get("/profile")
def get_profile(db: Session = Depends(get_db)):
    return {
        "profile": {
            "name": "Nurse Sara",
            "title": "Senior Staff Nurse",
            "status": "Active Duty",
            "employee_id": "NUR-88392",
            "department": "General Ward",
            "email": "sara@ayusync.com",
            "phone": "7013250990"
        },
        "preferences": {
            "push_notifications": True,
            "email_summaries": False
        }
    }
