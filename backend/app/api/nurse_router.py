from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import TriageQueue

router = APIRouter(prefix="/api/v1/nurse", tags=["nurse"])

@router.get("/triage")
def get_triage_dashboard(db: Session = Depends(get_db)):
    triage_items = db.query(TriageQueue).filter(TriageQueue.status == "OPEN").all()
    
    res = []
    for t in triage_items:
        res.append({
            "triage_id": t.id,
            "patient_id": t.patient_id,
            "severity": t.severity.value,
            "created_at": t.created_at
        })
        
    return {"status": "success", "triage_queue": res}
