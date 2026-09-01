from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import PharmacyOrder, Medication

router = APIRouter(prefix="/api/v1/pharmacy", tags=["pharmacy"])

@router.get("/prescriptions")
def get_prescriptions(db: Session = Depends(get_db)):
    orders = db.query(PharmacyOrder).all()
    
    res = []
    for o in orders:
        med = db.query(Medication).filter(Medication.id == o.medication_id).first()
        res.append({
            "order_id": o.id,
            "drug_name": med.drug_name if med else "Unknown",
            "status": o.status
        })
        
    return {"status": "success", "prescriptions": res}
