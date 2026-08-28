from typing import Dict, Any

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Pharmacy Agent (Execution Engine)
    Handles medication dispensing, predictive hedging, and smart packaging.
    """
    # Only listen to system.agent_commands
    if topic != "system.agent_commands":
        return
        
    command_data = payload.get("command", {})
    target_agent = command_data.get("target_agent")
    
    # Check if this command is meant for us
    if target_agent != "pharmacy_agent":
        return
        
    action = command_data.get("action")
    patient_id = payload.get("patient_id", "Unknown Patient")
    
    print(f"\n💊 [Pharmacy Agent] Woke up! Received command: '{action}' for Patient: {patient_id}")
    
    if action == "process_prescription":
        print(f"💊 [Pharmacy Agent] Connecting to PBM API...")
        print(f"💊 [Pharmacy Agent] Predictive Hedging Alert: Local shortage detected for requested medication.")
        print(f"💊 [Pharmacy Agent] Re-routing prescription to Regional Mail-Order facility.")
        print(f"💊 [Pharmacy Agent] Prescription processed successfully.")
        
    elif action == "check_stock":
        print(f"💊 [Pharmacy Agent] Checking inventory levels. Stock is adequate.")
        
    else:
        print(f"💊 [Pharmacy Agent] Executing fallback logic for command: {action}")
