from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from typing import Dict, Any
from .models.events import TelemetryEvent, VitalsPayload, EventSource
from .core.event_bus import event_bus
from .core.database_session import engine
from .models.database import Base
from .api.patient_router import router as patient_router
from .api.admin_router import router as admin_router
from .api.caregiver_router import router as caregiver_router

# Initialize the Database tables on startup (For local SQLite testing)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Ayusync Backend API",
    description="Core backend for the Ayusync Autonomous Care Coordination System",
    version="0.1.0"
)

# Enable CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API Routers
app.include_router(patient_router)
app.include_router(admin_router)
app.include_router(caregiver_router)

# Mount Static Files for Admin UI
import os
static_dir = os.path.join(os.path.dirname(__file__), "static")
if not os.path.exists(static_dir):
    os.makedirs(static_dir)
app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get("/admin", response_class=HTMLResponse)
async def admin_page():
    with open(os.path.join(static_dir, "admin.html"), "r") as f:
        return f.read()

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
