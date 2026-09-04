from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from app.core.database_session import get_db
from app.models.database import User, Patient, Condition, Medication, VitalSign, UserRole, CarePlan, CareTask, LabTest, ClinicalNote
from app.agents.chat_agent import ChatAgent
from app.agents.document_parser import process_medical_record
from fastapi import File, UploadFile, Form
import base64

ACTIVE_CHAT_SESSIONS: Dict[str, List[Dict]] = {}

router = APIRouter(prefix="/api/v1/patients", tags=["patients"])

class LoginPayload(BaseModel):
    username: str
    password: str

class SignupPayload(BaseModel):
    full_name: str
    phone_number: str
    username: str
    password: str

@router.post("/signup")
def signup_patient(payload: SignupPayload, db: Session = Depends(get_db)):
    # Check if username exists
    existing = db.query(User).filter(User.username == payload.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="Username already taken")
        
    import uuid
    from app.models.database import current_utc_time

    # Create User
    new_user = User(
        username=payload.username,
        hashed_password=payload.password, # In a real app, hash this!
        full_name=payload.full_name,
        phone_number=payload.phone_number,
        role=UserRole.PATIENT
    )
    db.add(new_user)
    db.commit()
    
    # Create empty Patient profile
    new_patient = Patient(
        id=str(uuid.uuid4()),
        user_id=new_user.id,
        date_of_birth=current_utc_time()
    )
    db.add(new_patient)
    db.commit()
    
    return {
        "status": "success",
        "patient_id": new_patient.id,
        "name": new_user.full_name
    }

@router.post("/login")
def login_patient(payload: LoginPayload, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == payload.username, User.role == UserRole.PATIENT).first()
    
    # In a real app, verify hashed_password properly
    if not user or user.hashed_password != payload.password:
        raise HTTPException(status_code=401, detail="Invalid username or password")
        
    patient_profile = db.query(Patient).filter(Patient.user_id == user.id).first()
    if not patient_profile:
        raise HTTPException(status_code=404, detail="Patient profile not found")
        
    return {
        "status": "success",
        "patient_id": patient_profile.id,
        "name": user.full_name
    }

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

@router.get("/{patient_id}/plan")
def get_recovery_plan(patient_id: str, date: str = None, db: Session = Depends(get_db)):
    from datetime import datetime
    if date:
        try:
            target_date = datetime.strptime(date, "%Y-%m-%d").date()
        except:
            target_date = datetime.now().date()
    else:
        target_date = datetime.now().date()
    # 1. Fetch Care Plan
    care_plan = db.query(CarePlan).filter(CarePlan.patient_id == patient_id).first()
    
    plan_data = {
        "title": "General Wellness Protocol",
        "progress_percent": 0,
        "description": "Standard daily wellness tracking."
    }
    
    if care_plan and care_plan.protocol_json:
        import json
        protocol = care_plan.protocol_json
        if isinstance(protocol, str):
            try:
                protocol = json.loads(protocol)
            except:
                protocol = {}
                
        if isinstance(protocol, dict):
            plan_data["title"] = protocol.get("title", "Post-Op Recovery Protocol")
            plan_data["progress_percent"] = protocol.get("progress_percent", 50)
            plan_data["description"] = protocol.get("description", "Follow your prescribed protocol.")
        
    # 2. Fetch Tasks for Today
    today_tasks = []
    
    # 2a. Real tasks
    tasks = db.query(CareTask).filter(CareTask.patient_id == patient_id).all()
    for t in tasks:
        if t.due_time and t.due_time.date() == target_date:
            is_completed = t.is_completed if target_date <= datetime.now().date() else False
            today_tasks.append({
                "id": t.id,
                "time": t.due_time.strftime("%I:%M %p"),
                "title": t.task_description,
                "subtitle": "Assigned Task",
                "icon": "clipboard",
                "is_completed": is_completed,
                "is_active": not is_completed
            })
            
    # Generate random completion for static tasks to make dates look dynamic for demo
    import random
    random.seed(f"{patient_id}_{target_date}")
    med_completed = random.choice([True, False]) if target_date < datetime.now().date() else False
    ai_completed = random.choice([True, False]) if target_date < datetime.now().date() else False
    vitals_completed = random.choice([True, False]) if target_date < datetime.now().date() else False
        
    # 2b. Synthesize Medication Tasks
    meds = db.query(Medication).filter(Medication.patient_id == patient_id, Medication.is_active == True).all()
    for m in meds:
        today_tasks.append({
            "id": f"med_{m.id}",
            "time": "8:00 AM",
            "title": "Take Medication",
            "subtitle": f"{m.drug_name} {m.dosage}",
            "icon": "pill",
            "is_completed": med_completed,
            "is_active": not med_completed
        })
        
    # 2c. Always append an AI Check-in
    today_tasks.append({
        "id": "ai_checkin",
        "time": "10:30 AM",
        "title": "AI Check-in",
        "subtitle": "Daily symptom log",
        "icon": "messageSquare",
        "is_completed": ai_completed,
        "is_active": not ai_completed
    })
    
    # 2d. Always append a Vitals Check
    today_tasks.append({
        "id": "check_vitals",
        "time": "09:00 AM",
        "title": "Check Vitals",
        "subtitle": "Record your heart rate, BP & O2",
        "icon": "activity",
        "is_completed": vitals_completed,
        "is_active": not vitals_completed
    })
    
    # Sort by actual time chronologically
    from datetime import datetime
    today_tasks.sort(key=lambda x: datetime.strptime(x["time"], "%I:%M %p"))

    return {
        "status": "success",
        "care_plan": plan_data,
        "today_tasks": today_tasks
    }

@router.get("/{patient_id}/labs")
def get_patient_labs(patient_id: str, db: Session = Depends(get_db)):
    labs = db.query(LabTest).filter(LabTest.patient_id == patient_id).order_by(LabTest.scheduled_time.desc()).all()
    
    import json
    results = []
    for lab in labs:
        res = None
        if lab.results_json:
            try:
                res = json.loads(lab.results_json)
            except:
                pass
        
        results.append({
            "id": lab.id,
            "test_name": lab.test_name,
            "scheduled_time": lab.scheduled_time.strftime("%b %d, %Y - %I:%M %p"),
            "status": lab.status,
            "results": res
        })
        
    return results

@router.get("/{patient_id}/reports-summary")
def get_reports_summary(patient_id: str, db: Session = Depends(get_db)):
    # Counts
    lab_count = db.query(LabTest).filter(LabTest.patient_id == patient_id).count()
    rx_count = db.query(Medication).filter(Medication.patient_id == patient_id).count()
    discharge_count = db.query(ClinicalNote).filter(
        ClinicalNote.patient_id == patient_id, 
        ClinicalNote.note_type == "DISCHARGE_SUMMARY"
    ).count()
    radiology_count = db.query(ClinicalNote).filter(
        ClinicalNote.patient_id == patient_id, 
        ClinicalNote.note_type == "RADIOLOGY"
    ).count()
    chat_summaries_count = db.query(ClinicalNote).filter(
        ClinicalNote.patient_id == patient_id, 
        ClinicalNote.note_type == "AI_CHAT_SUMMARY"
    ).count()
    
    # Recent documents
    recent_docs = []
    
    # 1. Latest Discharge Summary
    latest_discharge = db.query(ClinicalNote).filter(
        ClinicalNote.patient_id == patient_id,
        ClinicalNote.note_type == "DISCHARGE_SUMMARY"
    ).order_by(ClinicalNote.timestamp.desc()).first()
    
    if latest_discharge:
        recent_docs.append({
            "title": "Apollo Discharge Summary",
            "date": latest_discharge.timestamp.strftime("%b %d, %Y"),
            "meta": "PDF • 1.2 MB",
            "timestamp": latest_discharge.timestamp
        })
        
    # 2. Latest Prescription
    latest_rx = db.query(Medication).filter(
        Medication.patient_id == patient_id
    ).order_by(Medication.id.desc()).first() # Hacky ordering, could add timestamp
    
    # Just use current time minus 2 days for realistic Rx date
    from datetime import datetime, timedelta
    if latest_rx:
        recent_docs.append({
            "title": f"Dr. Uma Kanth Prescription",
            "date": (datetime.now() - timedelta(days=2)).strftime("%b %d, %Y"),
            "meta": "PDF • 450 KB",
            "timestamp": datetime.now() - timedelta(days=2)
        })
        
    # 3. Latest Lab
    latest_lab = db.query(LabTest).filter(
        LabTest.patient_id == patient_id
    ).order_by(LabTest.scheduled_time.desc()).first()
    
    if latest_lab:
        recent_docs.append({
            "title": f"{latest_lab.test_name} Result",
            "date": latest_lab.scheduled_time.strftime("%b %d, %Y"),
            "meta": "PDF • 800 KB",
            "timestamp": latest_lab.scheduled_time
        })
        
    # Sort recent docs by timestamp desc
    recent_docs.sort(key=lambda x: x["timestamp"], reverse=True)
    
    return {
        "status": "success",
        "counts": {
            "labs": lab_count,
            "prescriptions": rx_count,
            "discharge_summaries": discharge_count,
            "radiology": radiology_count,
            "chat_summaries": chat_summaries_count
        },
        "recent_documents": recent_docs[:2] # Top 2
    }

@router.get("/{patient_id}/discharge-summaries")
def get_discharge_summaries(patient_id: str, db: Session = Depends(get_db)):
    notes = db.query(ClinicalNote).filter(
        ClinicalNote.patient_id == patient_id,
        ClinicalNote.note_type == "DISCHARGE_SUMMARY"
    ).order_by(ClinicalNote.timestamp.desc()).all()
    
    return [{
        "id": note.id,
        "date": note.timestamp.strftime("%b %d, %Y"),
        "content_text": note.content_text
    } for note in notes]

@router.get("/{patient_id}/chat-summaries")
def get_chat_summaries(patient_id: str, db: Session = Depends(get_db)):
    notes = db.query(ClinicalNote).filter(
        ClinicalNote.patient_id == patient_id,
        ClinicalNote.note_type == "AI_CHAT_SUMMARY"
    ).order_by(ClinicalNote.timestamp.desc()).all()
    
    return [{
        "id": note.id,
        "date": note.timestamp.strftime("%b %d, %Y"),
        "content_text": note.content_text
    } for note in notes]

class ChatMessagePayload(BaseModel):
    text: str

@router.post("/{patient_id}/chat")
def send_chat_message(patient_id: str, payload: ChatMessagePayload, db: Session = Depends(get_db)):
    if patient_id not in ACTIVE_CHAT_SESSIONS:
        ACTIVE_CHAT_SESSIONS[patient_id] = []
        
    chat_history = ACTIVE_CHAT_SESSIONS[patient_id]
    
    agent = ChatAgent(db=db, patient_id=patient_id)
    response_text = agent.process_message(user_message=payload.text, chat_history=chat_history)
    
    ACTIVE_CHAT_SESSIONS[patient_id].append({"sender": "user", "text": payload.text})
    ACTIVE_CHAT_SESSIONS[patient_id].append({"sender": "ai", "text": response_text})
    
    return {
        "status": "success",
        "response": response_text
    }

@router.post("/{patient_id}/chat/summarize")
def summarize_chat(patient_id: str, db: Session = Depends(get_db)):
    if patient_id not in ACTIVE_CHAT_SESSIONS or not ACTIVE_CHAT_SESSIONS[patient_id]:
        return {"status": "success", "message": "No active chat"}
        
    agent = ChatAgent(db=db, patient_id=patient_id)
    summary_text = agent.summarize_chat(chat_history=ACTIVE_CHAT_SESSIONS[patient_id])
    
    note = ClinicalNote(
        patient_id=patient_id,
        note_type="AI_CHAT_SUMMARY",
        content_text=summary_text
    )
    db.add(note)
    db.commit()
    
    ACTIVE_CHAT_SESSIONS[patient_id] = []
    
    return {"status": "success", "message": "Saved"}

class VitalsPayload(BaseModel):
    heart_rate: Optional[int] = None
    bp_systolic: Optional[int] = None
    bp_diastolic: Optional[int] = None
    oxygen_saturation: Optional[int] = None

@router.post("/{patient_id}/vitals")
def log_vitals(patient_id: str, payload: VitalsPayload, db: Session = Depends(get_db)):
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    vital = VitalSign(
        patient_id=patient_id,
        heart_rate=payload.heart_rate,
        blood_pressure_systolic=payload.bp_systolic,
        blood_pressure_diastolic=payload.bp_diastolic,
        oxygen_saturation=payload.oxygen_saturation
    )
    db.add(vital)
    db.commit()
    
    return {"status": "success", "message": "Vitals logged successfully"}

@router.post("/{patient_id}/upload-document")
async def upload_document(patient_id: str, category: str = Form(...), file: UploadFile = File(...), db: Session = Depends(get_db)):
    """
    Receives an image or pdf of a medical document.
    Passes it to the OCR API to extract data.
    """
    try:
        contents = await file.read()
        filename = file.filename
        
        result = process_medical_record(patient_id, contents, filename, category, db)
        return result
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
