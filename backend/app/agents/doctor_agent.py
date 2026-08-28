import json
from typing import Dict, Any

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Doctor Agent (Actionable / Execution Layer)
    Listens for system.agent_commands and handles critical escalations to the physician.
    """
    if topic != "system.agent_commands":
        return
        
    command_data = payload.get("command", {})
    if command_data.get("target_agent") != "doctor_agent":
        return

    patient_id = payload.get("patient_id", "unknown")
    action = command_data.get("action", "unknown_action")
    parameters = command_data.get("parameters", {})
    urgency = command_data.get("urgency", "normal")
    
    print(f"\n🚨 [Doctor Agent] WAKING UP for command: {action} (Urgency: {urgency})")
    
    # Mocking the execution
    if action == "page_doctor":
        reason = parameters.get("reason", "No reason provided")
        print(f"🚨 [Doctor Agent] PAGING Dr. Smith (On-Call) for Patient {patient_id}: 'CRITICAL: {reason}'")
    else:
        print(f"🚨 [Doctor Agent] Executing action {action} with parameters {parameters} for Doctor's Dashboard.")
