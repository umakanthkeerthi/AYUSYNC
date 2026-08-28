from typing import Dict, Any
from ..core.database_session import SessionLocal
from ..models.database import VitalSign, Patient, User, UserRole
import uuid
from datetime import datetime
from ..models.events import StateChangeEvent, EventSource, StateUpdatePayload, TelemetryEvent, VitalsPayload
from ..core.event_bus import event_bus
import re

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    In AWS, this function would be triggered by an EventBridge rule routing to an AWS Lambda.
    For our PoC, the EventBus triggers it directly.
    """
    print(f"⚙️ Patient State Agent woke up to process: {topic}")
    
    if topic == "telemetry.vitals":
        _process_vitals(payload)
    else:
        print(f"⚙️ Ignoring unhandled topic: {topic}")

def _process_vitals(payload: Dict[str, Any]):
    db = SessionLocal()
    try:
        patient_id = payload.get("patient_id")
        vitals_data = payload.get("vitals", {})
        
        # 1. Very basic check: Does the patient exist? (If not, create a mock one for the PoC)
        patient = db.query(Patient).filter(Patient.id == patient_id).first()
        if not patient:
            print(f"⚠️ Patient {patient_id} not found in DB. Creating mock patient for PoC.")
            mock_user = User(id=str(uuid.uuid4()), role=UserRole.PATIENT, full_name="Mock Patient", phone_number="+15550001234")
            patient = Patient(id=patient_id, user_id=mock_user.id, date_of_birth=datetime(1980, 1, 1))
            db.add(mock_user)
            db.add(patient)
            db.commit()
            print("✅ Mock Patient created.")

        # 2. Save the vitals to the Single Source of Truth database
        new_vital = VitalSign(
            patient_id=patient.id,
            heart_rate=vitals_data.get("heart_rate"),
            blood_pressure_systolic=vitals_data.get("blood_pressure_systolic"),
            blood_pressure_diastolic=vitals_data.get("blood_pressure_diastolic"),
            oxygen_saturation=vitals_data.get("oxygen_saturation")
        )
        db.add(new_vital)
        db.commit()
        db.refresh(new_vital)
        
        print(f"💾 Patient State Agent successfully saved Vitals to PostgreSQL! (Record ID: {new_vital.id})")
        
        # Fire state.updated event back to the bus
        state_event = StateChangeEvent(
            patient_id=patient_id,
            source=EventSource.STATE_AGENT,
            state_update=StateUpdatePayload(
                changed_fields=["vitals"],
                snapshot_summary={"heart_rate": new_vital.heart_rate, "bp": f"{new_vital.blood_pressure_systolic}/{new_vital.blood_pressure_diastolic}"}
            )
        )
        event_bus.publish(state_event)
        
    except Exception as e:
        print(f"❌ Patient State Agent Failed: {str(e)}")
        db.rollback()
    finally:
        db.close()
