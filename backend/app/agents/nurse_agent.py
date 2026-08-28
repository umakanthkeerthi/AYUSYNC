import json
from typing import Dict, Any

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Nurse Agent (Actionable / Execution Layer)
    Listens for system.agent_commands and handles manual triage or follow-up tasks.
    """
    if topic != "system.agent_commands":
        return
        
    command_data = payload.get("command", {})
    if command_data.get("target_agent") != "nurse_agent":
        return

    patient_id = payload.get("patient_id", "unknown")
    action = command_data.get("action", "unknown_action")
    parameters = command_data.get("parameters", {})
    urgency = command_data.get("urgency", "normal")
    
    print(f"\n🩺 [Nurse Agent] WAKING UP for command: {action} (Urgency: {urgency})")
    
    # Mocking the execution
    if action == "follow_up_call":
        reason = parameters.get("reason", "routine check")
        print(f"🩺 [Nurse Agent] ADDING TASK to Nurse Station Dashboard: 'Call Patient {patient_id} regarding {reason}.'")
    else:
        print(f"🩺 [Nurse Agent] Executing action {action} with parameters {parameters}.")
