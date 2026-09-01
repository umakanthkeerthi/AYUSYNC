from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database_session import get_db
from app.models.database import AmbulanceDriver, EmergencyDispatch, DispatchStatus

router = APIRouter(prefix="/api/v1/driver", tags=["driver"])

@router.get("/sos-dispatch")
def check_dispatch(driver_user_id: str, db: Session = Depends(get_db)):
    driver = db.query(AmbulanceDriver).filter(AmbulanceDriver.user_id == driver_user_id).first()
    if not driver:
        return {"status": "error", "message": "Driver not found"}

    dispatch = db.query(EmergencyDispatch).filter(
        EmergencyDispatch.driver_id == driver.id,
        EmergencyDispatch.status.in_([DispatchStatus.PENDING, DispatchStatus.EN_ROUTE])
    ).first()

    if not dispatch:
        return {"status": "success", "dispatch": None}
        
    return {
        "status": "success",
        "dispatch": {
            "dispatch_id": dispatch.id,
            "patient_id": dispatch.patient_id,
            "pickup_location": dispatch.pickup_location,
            "lat": dispatch.pickup_lat,
            "lng": dispatch.pickup_lng,
            "status": dispatch.status.value
        }
    }
