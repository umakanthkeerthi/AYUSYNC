from fastapi import FastAPI, HTTPException
from typing import Dict, Any
from .models.events import TelemetryEvent, VitalsPayload, EventSource
from .core.event_bus import event_bus
from .core.database_session import engine
from .models.database import Base

# Initialize the Database tables on startup (For local SQLite testing)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Ayusync Backend API",
    description="Core backend for the Ayusync Autonomous Care Coordination System",
    version="0.1.0"
)

@app.get("/")
async def root():
    return {"status": "ok", "message": "Ayusync Backend is running"}

@app.get("/health")
async def health_check():
    # TODO: Add database and EventBridge connection checks here
    return {"status": "healthy"}

@app.post("/api/v1/simulate/vitals")
async def simulate_vitals(patient_id: str, heart_rate: int, systolic: int = None, diastolic: int = None):
    """
    MOCK PATIENT AGENT
    Simulates receiving raw data from a smartwatch or patient SMS, 
    packaging it into our strict Pydantic Schema, and throwing it on the Event Bus.
    """
    try:
        event = TelemetryEvent(
            patient_id=patient_id,
            source=EventSource.PATIENT_AGENT,
            vitals=VitalsPayload(
                heart_rate=heart_rate,
                blood_pressure_systolic=systolic,
                blood_pressure_diastolic=diastolic
            )
        )
        
        # Publish to AWS EventBridge
        result = event_bus.publish(event)
        
        return {
            "status": "success", 
            "message": "Data published to Event Bus",
            "event_id": event.event_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
