import json
from typing import Dict, Any

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Caregiver Agent (Actionable / Execution Layer)
    Listens for system.agent_commands and notifies the patient's family/emergency contacts.
    """
    if topic != "system.agent_commands":
        return
        
    command_data = payload.get("command", {})
    if command_data.get("target_agent") != "caregiver_agent":
        return

    patient_id = payload.get("patient_id", "unknown")
    action = command_data.get("action", "unknown_action")
    parameters = command_data.get("parameters", {})
    urgency = command_data.get("urgency", "normal")
    
    print(f"\n👨‍👩‍👦 [Caregiver Agent] WAKING UP for command: {action} (Urgency: {urgency})")
    
    # Mocking the execution
    if action == "update_family":
        message = parameters.get("message", "Condition update.")
        print(f"👨‍👩‍👦 [Caregiver Agent] SENDING SMS to Emergency Contact for Patient {patient_id}: '{message}'")
    else:
        print(f"👨‍👩‍👦 [Caregiver Agent] Executing action {action} with parameters {parameters}.")
