from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.core.database_session import get_db
from app.models.database import LabOrder, LabTest, Patient, User

router = APIRouter(prefix="/api/v1/lab", tags=["lab"])

class LoginPayload(BaseModel):
    username: str
    password: str

@router.post("/login")
def login(payload: LoginPayload):
    if payload.username == "Ayusync_Lab" and payload.password == "password123":
        return {"status": "success", "token": "lab_token_123", "user": {"name": "Admin", "role": "lab"}}
    raise HTTPException(status_code=401, detail="Invalid credentials")

@router.get("/dashboard_stats")
def get_dashboard_stats(db: Session = Depends(get_db)):
    tests = db.query(LabTest).all()
    pending = sum(1 for t in tests if t.status == "Processing")
    collected = sum(1 for t in tests if t.status == "Results Ready")
    # For UI variety, mock some numbers if tests are low
    return {
        "status": "success",
        "pending": str(pending if pending > 0 else 12),
        "collected": str(collected if collected > 0 else 8),
        "processing": "15",
        "critical": "3"
    }

@router.get("/queue")
def get_queue(db: Session = Depends(get_db)):
    tests = db.query(LabTest).all()
    res = []
    
    # If no tests exist in the DB, fallback to an empty list, UI will handle
    for t in tests:
        if t.status == "Completed": continue
        
        patient_name = "Unknown"
        patient = db.query(Patient).filter(Patient.id == t.patient_id).first()
        if patient:
            user = db.query(User).filter(User.id == patient.user_id).first()
            if user: patient_name = user.full_name
                
        ui_status = "Pending"
        urgency = "Routine"
        risk = "25"
        
        if t.status == "Processing":
            ui_status = "Processing"
        elif t.status == "Results Ready":
            ui_status = "Critical"
            urgency = "Urgent"
            risk = "80"
        
        res.append({
            "id": t.id,
            "patient": patient_name,
            "test": t.test_name,
            "time": "09:00 AM",
            "urgency": urgency,
            "risk": risk,
            "status": ui_status
        })
    return {"status": "success", "queue": res}

@router.get("/samples")
def get_samples(db: Session = Depends(get_db)):
    tests = db.query(LabTest).all()
    res = []
    for t in tests:
        patient_name = "Unknown"
        patient = db.query(Patient).filter(Patient.id == t.patient_id).first()
        if patient:
            user = db.query(User).filter(User.id == patient.user_id).first()
            if user: patient_name = user.full_name
        
        res.append({
            "id": f"SPL-{t.id[:4].upper()}",
            "patient": patient_name,
            "test": t.test_name,
            "type": "Blood",
            "status": "Collected" if t.status == "Processing" else t.status
        })
    return {"status": "success", "samples": res}

@router.get("/results")
def get_results(db: Session = Depends(get_db)):
    tests = db.query(LabTest).filter(LabTest.status == "Completed").all()
    res = []
    for t in tests:
        patient_name = "Unknown"
        patient = db.query(Patient).filter(Patient.id == t.patient_id).first()
        if patient:
            user = db.query(User).filter(User.id == patient.user_id).first()
            if user: patient_name = user.full_name
        
        # Some basic mocked interpretation
        test_val = "Normal"
        if "Hemoglobin" in t.test_name: test_val = "6.2%"
        
        res.append({
            "id": f"SPL-{t.id[:4].upper()}",
            "patient": patient_name,
            "test": t.test_name,
            "result": t.results_json if t.results_json else test_val,
            "status": "Normal"
        })
    return {"status": "success", "results": res}

@router.get("/reports")
def get_reports(db: Session = Depends(get_db)):
    tests = db.query(LabTest).all()
    tests_count = len(tests)
    completed_tests = [t for t in tests if t.status == "Completed"]
    
    table_data = []
    # Sort completed tests by scheduled time descending (newest first)
    completed_tests.sort(key=lambda x: x.scheduled_time.timestamp() if x.scheduled_time else 0, reverse=True)
    
    for t in completed_tests:
        patient_name = "Unknown"
        patient = db.query(Patient).filter(Patient.id == t.patient_id).first()
        if patient:
            user = db.query(User).filter(User.id == patient.user_id).first()
            if user: patient_name = user.full_name
            
        date_str = t.scheduled_time.strftime("%b %d, %Y") if t.scheduled_time else "Unknown"
        table_data.append({
            'date': date_str,
            'patient': patient_name,
            'tests': t.test_name,
            'status': 'Delivered',
            'revenue': '₹1,500' # mock price
        })
        
    return {
        "status": "success",
        "total_revenue": f"₹{len(completed_tests) * 1500}",
        "orders_delivered": str(len(completed_tests)),
        "avg_turnaround": "4.5 hrs",
        "pending_bills": "₹0",
        "table_data": table_data
    }

@router.get("/analytics")
def get_analytics(db: Session = Depends(get_db)):
    tests = db.query(LabTest).all()
    
    blood_count = sum(1 for t in tests if "Blood" in t.test_name or "CBC" in t.test_name or "Panel" in t.test_name)
    other_count = len(tests) - blood_count
    total = len(tests) if len(tests) > 0 else 1
    
    blood_pct = (blood_count / total) * 100
    other_pct = (other_count / total) * 100
    
    return {
        "status": "success",
        "blood_percentage": round(blood_pct),
        "other_percentage": round(other_pct)
    }
