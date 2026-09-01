from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import PriorAuthorization

router = APIRouter(prefix="/api/v1/insurance", tags=["insurance"])

@router.get("/claims")
def get_claims(db: Session = Depends(get_db)):
    claims = db.query(PriorAuthorization).all()
    
    res = []
    for c in claims:
        res.append({
            "id": c.id,
            "patient_id": c.patient_id,
            "request_type": c.request_type,
            "status": c.status
        })
        
    return {"status": "success", "claims": res}
