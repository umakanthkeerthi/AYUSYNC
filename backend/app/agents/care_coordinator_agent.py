import json
from typing import Dict, Any
from ..core.event_bus import event_bus
from ..models.events import AgentCommandEvent, EventSource, CommandPayload

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Care Coordinator Agent (The Scheduler)
    Listens for analysis.plan_proposed. Translates tactical plans into specific Agent Commands.
    """
    if topic != "analysis.plan_proposed":
        return

    print(f"🗓️ [Care Coordinator Agent] Received proposed plan for Patient: {payload.get('patient_id')}")
    
    patient_id = payload.get("patient_id")
    data = payload.get("data", {})
    proposed_actions = data.get("proposed_actions", [])
    
    if not proposed_actions:
        return
        
    print(f"⚙️ [Care Coordinator Agent] Translating {len(proposed_actions)} actions into System Commands...")
    
    for action in proposed_actions:
        if action == "page_on_call_doctor":
            # Fire command to Doctor Agent (Actionable Agent)
            cmd = AgentCommandEvent(
                patient_id=patient_id,
                source=EventSource.POLICY_ENGINE, # Or CARE_COORDINATOR
                command=CommandPayload(
                    target_agent="doctor_agent",
                    action="page_doctor",
                    parameters={"reason": data.get("reason", "High Risk")},
                    urgency="critical"
                )
            )
            event_bus.publish(cmd)
            print(f"🚀 [Care Coordinator Agent] Scheduled command: {action} -> doctor_agent")
        
        elif action == "request_new_vitals_in_1_hour":
            # Fire command to Patient Agent to message the patient
            cmd = AgentCommandEvent(
                patient_id=patient_id,
                source=EventSource.POLICY_ENGINE,
                command=CommandPayload(
                    target_agent="patient_agent",
                    action="request_vitals",
                    parameters={"delay_hours": 1},
                    urgency="high"
                )
            )
            event_bus.publish(cmd)
            print(f"🚀 [Care Coordinator Agent] Scheduled command: {action} -> patient_agent")
