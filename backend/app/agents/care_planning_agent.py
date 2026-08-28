import json
from typing import Dict, Any
from ..core.event_bus import event_bus
from ..models.events import AnalysisEvent, EventSource

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Care Planning Agent (The Strategist)
    Listens for analysis.risk_scored. Enforces the doctor's strictly prescribed plan.
    """
    if topic != "analysis.risk_scored":
        return

    print(f"📋 [Care Planning Agent] Evaluating new Risk Score for Patient: {payload.get('patient_id')}")
    
    patient_id = payload.get("patient_id")
    data = payload.get("data", {})
    risk_score = data.get("risk_score", 0)
    
    # 1. Load Doctor's strict Care Plan (Mocked for PoC, normally fetched from DB)
    doctor_protocol = {
        "max_acceptable_risk": 50,
        "actions_if_exceeded": ["page_on_call_doctor", "request_new_vitals_in_1_hour"]
    }
    
    proposed_plan = []
    
    if risk_score > doctor_protocol["max_acceptable_risk"]:
        print(f"⚠️ [Care Planning Agent] Risk Score ({risk_score}%) exceeds doctor's threshold!")
        print(f"🛡️ [Care Planning Agent] Strictly applying doctor's protocol: {doctor_protocol['actions_if_exceeded']}")
        proposed_plan = doctor_protocol["actions_if_exceeded"]
    else:
        print("✅ [Care Planning Agent] Patient is within safe parameters.")
        
    if proposed_plan:
        plan_event = AnalysisEvent(
            patient_id=patient_id,
            source=EventSource.PLANNING_AGENT,
            topic="analysis.plan_proposed",
            data={
                "proposed_actions": proposed_plan,
                "reason": f"Risk score is {risk_score}%"
            }
        )
        event_bus.publish(plan_event)
