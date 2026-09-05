import json
from typing import Dict, Any
from ..core.event_bus import event_bus
from ..models.events import TriggerEvent, EventSource, TriggerPayload

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Monitoring Agent (The Watchdog)
    Listens for state.updated events. If it spots alarming data, it fires internal triggers.
    """
    if topic != "state.updated":
        return

    print(f"👀 [Monitoring Agent] Inspecting state.updated for Patient: {payload.get('patient_id')}")
    
    patient_id = payload.get("patient_id")
    state_update = payload.get("state_update", {})
    changed_fields = state_update.get("changed_fields", [])
    snapshot = state_update.get("snapshot_summary", {})
    
    if "vitals" in changed_fields:
        # Lightweight rules engine
        hr = snapshot.get("heart_rate")
        bp_str = snapshot.get("bp")
        
        needs_risk_assessment = False
        reason = ""
        
        if hr and (hr > 100 or hr < 50):
            needs_risk_assessment = True
            reason += f"Abnormal HR ({hr}). "
            
        if bp_str:
            try:
                sys, dia = map(int, bp_str.split('/'))
                if sys > 140 or dia > 90 or sys < 90 or dia < 60:
                    needs_risk_assessment = True
                    reason += f"Abnormal BP ({sys}/{dia}). "
            except:
                pass
                
        if not reason:
            reason = "Vitals check"
            
        print(f"⚠️ [Monitoring Agent] Triggering Risk Assessment. Reason: {reason}")
        trigger_event = TriggerEvent(
            patient_id=patient_id,
            source=EventSource.MONITORING_AGENT,
            topic="trigger.risk_assessment",
            trigger=TriggerPayload(
                trigger_type="risk_assessment",
                reason=reason.strip()
            )
        )
        event_bus.publish(trigger_event)
