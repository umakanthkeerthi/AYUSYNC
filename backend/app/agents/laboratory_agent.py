from typing import Dict, Any

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Laboratory Agent (Execution Engine)
    Coordinates diagnostics, schedules tests, and ingests reports via HL7/FHIR integrations.
    (Note: Drone dispatch functionality is disabled for this phase).
    """
    # Only listen to system.agent_commands
    if topic != "system.agent_commands":
        return
        
    command_data = payload.get("command", {})
    target_agent = command_data.get("target_agent")
    
    # Check if this command is meant for us
    if target_agent != "laboratory_agent":
        return
        
    action = command_data.get("action")
    patient_id = payload.get("patient_id", "Unknown Patient")
    
    print(f"\n🔬 [Laboratory Agent] Woke up! Received command: '{action}' for Patient: {patient_id}")
    
    if action == "schedule_test":
        print(f"🔬 [Laboratory Agent] Connecting to Diagnostics Partner API...")
        print(f"🔬 [Laboratory Agent] Scheduling phlebotomist home-visit for routine testing.")
        print(f"🔬 [Laboratory Agent] Phlebotomy appointment successfully booked.")
        
    elif action == "reflex_test":
        print(f"🔬 [Laboratory Agent] Critical abnormalities detected in primary panel.")
        print(f"🔬 [Laboratory Agent] Autonomous Reflex Testing Negotiation initiated.")
        print(f"🔬 [Laboratory Agent] Successfully ordered secondary blood smear on existing sample before disposal.")
        
    else:
        print(f"🔬 [Laboratory Agent] Executing fallback logic for command: {action}")
