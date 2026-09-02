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
    if payload.username == "Ayusync_nurse" and payload.password == "password123":
        return {"status": "success", "token": "nurse_token_123", "user": {"name": "Nurse Clara", "role": "nurse"}}
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
            "triage_id": t.id,
            "patient_name": get_patient_name(db, t.patient_id),
            "severity": t.severity.value,
            "created_at": t.created_at.isoformat() if t.created_at else None
        })
        
    return {
        "status": "success",
        "urgent_count": urgent_count,
        "followup_count": pending_tasks,
        "ontrack_count": completed_tasks,
        "total_patients": total_patients,
        "queue": queue
    }

@router.get("/tasks")
def get_tasks(db: Session = Depends(get_db)):
    tasks = db.query(CareTask).filter(CareTask.assigned_role == "NURSE").all()
    medium_triages = db.query(TriageQueue).filter(TriageQueue.severity == "MEDIUM", TriageQueue.status == "OPEN").all()
    
    res = []
    for t in tasks:
        status = "Completed" if t.is_completed else "Pending"
        res.append({
            "task_id": t.id,
            "patient_name": get_patient_name(db, t.patient_id),
            "description": t.task_description,
            "due_time": t.due_time.isoformat() if t.due_time else None,
            "status": status,
            "type": "CARE_TASK"
        })
        
    for t in medium_triages:
        res.append({
            "task_id": t.id,
            "patient_name": get_patient_name(db, t.patient_id),
            "description": "Triage Review (Medium Severity)",
            "due_time": t.created_at.isoformat() if t.created_at else None,
            "status": "Pending",
            "type": "TRIAGE"
        })
        
    return {"status": "success", "tasks": res}

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
            "heart_rate": vitals.heart_rate if vitals else "--",
            "blood_pressure": f"{vitals.blood_pressure_systolic}/{vitals.blood_pressure_diastolic}" if vitals and vitals.blood_pressure_systolic else "--/--",
            "severity": severity
        })
    return {"status": "success", "patients": res}

@router.get("/visits")
def get_visits(db: Session = Depends(get_db)):
    appointments = db.query(Appointment).filter(Appointment.status == "SCHEDULED").all()
    res = []
    for a in appointments:
        res.append({
            "visit_id": a.id,
            "patient_name": get_patient_name(db, a.patient_id),
            "date": a.scheduled_time.strftime("%b %d, %Y") if a.scheduled_time else "Unknown",
            "time": a.scheduled_time.strftime("%I:%M %p") if a.scheduled_time else "Unknown"
        })
    return {"status": "success", "visits": res}

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
        "status": "success",
        "profile": {
            "name": "Nurse Clara",
            "role": "Senior Staff Nurse",
            "email": "clara@ayusync.com",
            "phone": "+1 555-0198",
            "department": "General Ward",
            "employee_id": "NUR-88392"
        }
    }
