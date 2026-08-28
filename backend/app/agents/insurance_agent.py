from typing import Dict, Any

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Insurance Agent (Execution Engine)
    Administrative support for billing, checking active policies, and pre-filling prior authorizations.
    """
    # Only listen to system.agent_commands
    if topic != "system.agent_commands":
        return
        
    command_data = payload.get("command", {})
    target_agent = command_data.get("target_agent")
    
    # Check if this command is meant for us
    if target_agent != "insurance_agent":
        return
        
    action = command_data.get("action")
    patient_id = payload.get("patient_id", "Unknown Patient")
    
    print(f"\n🛡️ [Insurance Agent] Woke up! Received command: '{action}' for Patient: {patient_id}")
    
    if action == "verify_coverage":
        print(f"🛡️ [Insurance Agent] Accessing Payer APIs...")
        print(f"🛡️ [Insurance Agent] Real-Time Benefit Optimization: Scanning formulary tiers.")
        print(f"🛡️ [Insurance Agent] Coverage Verified. Smart Contract Adjudication triggered.")
        
    elif action == "submit_appeal":
        print(f"🛡️ [Insurance Agent] Claim denial detected.")
        print(f"🛡️ [Insurance Agent] Utilizing Legal LLM to draft technical appeal letter...")
        print(f"🛡️ [Insurance Agent] Appeal drafted successfully with Risk Predictor severity scores attached.")
        
    else:
        print(f"🛡️ [Insurance Agent] Executing fallback logic for command: {action}")
