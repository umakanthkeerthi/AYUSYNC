import json
from typing import Dict, Any
from ..core.event_bus import event_bus
from ..models.events import AnalysisEvent, EventSource

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Medication Adherence Agent (The Tracker)
    Listens for trigger.adherence_check events.
    """
    if topic != "trigger.adherence_check":
        return

    print(f"💊 [Medication Adherence Agent] Calculating adherence for Patient: {payload.get('patient_id')}")
    patient_id = payload.get("patient_id")
    
    # Normally queries the database for AdherenceLog to compute rolling percentage
    adherence_score = 85 # Mock score
    
    print(f"📈 [Medication Adherence Agent] 30-Day Adherence Score: {adherence_score}%")
    
    # Broadcast the analysis
    event = AnalysisEvent(
        patient_id=patient_id,
        source=EventSource.ADHERENCE_AGENT,
        topic="analysis.adherence_scored",
        data={"adherence_score": adherence_score}
    )
    event_bus.publish(event)
