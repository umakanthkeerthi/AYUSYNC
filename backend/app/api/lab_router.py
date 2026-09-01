from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import LabOrder

router = APIRouter(prefix="/api/v1/lab", tags=["lab"])

@router.get("/orders")
def get_lab_orders(db: Session = Depends(get_db)):
    orders = db.query(LabOrder).filter(LabOrder.status == "SCHEDULED").all()
    
    res = []
    for o in orders:
        res.append({
            "order_id": o.id,
            "patient_id": o.patient_id,
            "test_type": o.test_type,
            "status": o.status
        })
        
    return {"status": "success", "orders": res}
